// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

public final class SearchEngine<Value> {
  public typealias Element = (key: String, value: Value)

  private var invertedFile: InvertedIndex
  private var tree: TSTree<Value>

  var gramSize: Int { invertedFile.gramSize }
  var count: Int { tree.count }

  // MARK: - Initialization

  public init(gramSize: Int) {
    self.invertedFile = InvertedIndex(gramSize: gramSize)
    self.tree = .init()
  }

  // MARK: - CRUD Operations

  /// Insert list of key-value pairs. In case a key already exists, old value
  /// is replaced.
  public func insert<C: Collection<Element>>(contentsOf elements: C) {
    invertedFile.addDocuments(elements.lazy.map(\.key))
    elements.shuffled()  // shuffle to improve balance
      .forEach { key, value in tree.insert(key, value) }
  }

  /// Insert key-value pair. If key already exists, old value is replaced.
  /// - Important: Adding keys in alphabetical order results in bad performance.
  ///     Prefer batch insertion with ``insert(contentsOf:)`` for better performance.
  public func insert(_ key: String, value: Value) {
    invertedFile.addDocument(key)
    tree.insert(key, value)
  }

  /// Delete key (and associated value) from the data set.
  public func delete(_ key: String) {
    invertedFile.delete(key)
    tree.delete(key)
  }

  /// Update the value associated with key.
  public func update(_ key: String, newValue: Value) {
    delete(key)
    insert(key, value: newValue)
  }

  // MARK: - Query Operations

  /// Get the value associated with key in a case-sensitive manner.
  public func get(_ key: String) -> Value? {
    guard let value = tree.get(key) else { return nil }
    return value
  }

  public func search(
    _ query: String, _ maxResults: Int, _ enableFuzzy: Bool = true
  ) -> [Result] {
    precondition(query.isEmpty == false)

    var quota = maxResults
    var keySet = Set<String>()
    var results = [Result]()

    func addResults(_ phaseResults: [Element], type: MatchSpec) {
      phaseResults.forEach { keySet.insert($0.key) }
      quota -= phaseResults.count

      let phaseResults = phaseResults.map { Result(key: $0, value: $1, matchSpec: type) }
      results.append(contentsOf: phaseResults)
    }

    switch query.count {
    case 1:
      let prefixResults = prefixSearch(query, maxResults: quota)
      addResults(prefixResults, type: .prefix(caseSensitive: true, length: query.length))

      let other = query.first!.isUppercase ? query.lowercased() : query.uppercased()
      guard other != query else { break }
      let otherResults = prefixSearch(other, maxResults: quota)
      addResults(otherResults, type: .prefix(caseSensitive: false, length: query.length))

    default:
      assert(query.count > 1)
      let prefixResults = prefixSearch(query, maxResults: quota)
      addResults(prefixResults, type: .prefix(caseSensitive: true, length: query.length))
    }

    guard quota > 0 else { return results }

    // obtain n-gram search results
    let nGramResults = nGramSearch(query, maxResults: quota)
      .filter { key, _ in !keySet.contains(key) }
    addResults(nGramResults, type: .nGram(length: query.length))

    guard quota > 0, enableFuzzy else { return results }

    // obtain subsequence search results
    let fuzzyResults = fuzzySearch(query, maxResults: quota)
      .filter { key, _ in !keySet.contains(key) }
    addResults(fuzzyResults, type: .subSequence)

    return results
  }

  /// Enumerate all elements in the data set.
  /// - Parameter body: A closure that takes an element and returns a Boolean value.
  ///     If the closure returns false, enumeration stops.
  public func enumerateElements(_ body: (Element) -> Bool) {
    tree.enumerateKeysAndValues { key, value in
      let element = (key, value)
      return body(element)
    }
  }

  /// Prefix match
  private func prefixSearch(_ query: String, maxResults: Int) -> [Element] {
    guard query.count >= 1 else { return [] }
    return tree.search(withPrefix: query, maxResults: maxResults)
      .compactMap { key in tree.get(key).map { (key, $0) } }
  }

  /// N-Gram match
  private func nGramSearch(_ query: String, maxResults: Int) -> [Element] {
    invertedFile.search(query).lazy
      .compactMap { key in self.tree.get(key).map { (key, $0) } }
      .prefix(maxResults)
      .map { $0 }
  }

  /// Subsequence match
  private func fuzzySearch(_ query: String, maxResults: Int) -> [Element] {
    var matches: [Element] = []
    tree.enumerateKeysAndValues { key, value in
      guard query.lowercased().isSubsequence(of: key.lowercased())
      else { return true }
      matches.append((key, value))
      return matches.count < maxResults
    }
    return matches.sorted { $0.key.count < $1.key.count }
  }

  // MARK: - Maintenance

  /// Clear zombie elements resulted from deletions.
  public func compact() { invertedFile.compact() }

  // MARK: - Type

  public struct Result: Equatable, Comparable {
    let key: String
    let value: Value
    let matchSpec: MatchSpec

    init(key: String, value: Value, matchSpec: MatchSpec) {
      self.key = key
      self.value = value
      self.matchSpec = matchSpec
    }

    private var score: Double {
      switch matchSpec {
      case .equal(let b, _): return b ? 1 : 0
      case .prefix(let b, let length): return Double(length) * 2 + (b ? 0.5 : 0)
      case .subString(_, let length): return Double(length) * 1.2
      case .prefixPlus(let b, let length): return Double(length) * 2 + (b ? 0.5 : 0)
      case .subStringPlus(_, let length): return Double(length) * 1.2
      case .nGram(let length): return Double(length)
      case .nGramPlus(let length): return Double(length)
      case .subSequence: return 0
      }
    }

    private var rank: Int { matchSpec.rank }

    func with(matchSpec: MatchSpec) -> Result {
      Result(key: key, value: value, matchSpec: matchSpec)
    }

    public static func == (lhs: Result, rhs: Result) -> Bool {
      lhs.key == rhs.key && lhs.matchSpec == rhs.matchSpec
    }

    public static func < (lhs: Result, rhs: Result) -> Bool {
      func isScoreFirst(_ result: Result) -> Bool {
        switch result.matchSpec {
        case .equal: return false
        case .prefix, .prefixPlus: return true
        case .subString, .subStringPlus: return true
        case .nGram, .nGramPlus, .subSequence: return false
        }
      }

      // resolve comparison with score & rank

      if isScoreFirst(lhs) && isScoreFirst(rhs) {
        if lhs.score != rhs.score {
          return lhs.score > rhs.score
        }
        else if lhs.rank != rhs.rank {
          return lhs.rank < rhs.rank
        }
      }
      else {
        if lhs.rank != rhs.rank {
          return lhs.rank < rhs.rank
        }
        else if lhs.score != rhs.score {
          return lhs.score > rhs.score
        }
      }

      // special case for substring match

      switch (lhs.matchSpec, rhs.matchSpec) {
      case let (.subString(loc, len), .subString(rloc, rlen)),
        let (.subStringPlus(loc, len), .subStringPlus(rloc, rlen)):
        if loc != rloc {
          return loc < rloc
        }
        else if len != rlen {
          return len > rlen
        }
      default: break
      }

      // compare key

      let llower = lhs.key.lowercased()
      let rlower = rhs.key.lowercased()

      if llower != rlower {
        return llower < rlower
      }
      else {
        return lhs.key < rhs.key
      }
    }
  }

  public enum MatchSpec: Equatable {
    case equal(caseSensitive: Bool, length: Int)
    case prefix(caseSensitive: Bool, length: Int)
    case subString(location: Int, length: Int)

    /// prefix(length) + subsequence match
    case prefixPlus(caseSensitive: Bool, length: Int)
    /// substring(location, length) + subsequence match
    case subStringPlus(location: Int, length: Int)

    /// n-gram match for query(length)
    case nGram(length: Int)
    /// n-gram match for query(length) + subsequence match
    case nGramPlus(length: Int)
    case subSequence

    fileprivate var rank: Int {
      switch self {
      case .equal(let b, _): return b ? 0 : 2
      case .prefix(let b, _): return b ? 4 : 6
      case .subString: return 8
      case .prefixPlus(let b, _): return b ? 10 : 12
      case .subStringPlus: return 14
      case .nGram: return 16
      case .nGramPlus: return 18
      case .subSequence: return 20
      }
    }
  }

}
