// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

public final class SearchEngine<Value> {
  public typealias Element = (key: String, value: Value)

  public struct Result: Equatable, Comparable, CustomStringConvertible {
    let key: String
    let value: Value
    let matchType: MatchSpec
    let score: Int

    init(key: String, value: Value, matchType: MatchSpec, score: Int = 0) {
      self.key = key
      self.value = value
      self.matchType = matchType
      self.score = score
    }

    var isPrefix: Bool { matchType.isPrefix }
    var isPrefixPlus: Bool { matchType.isPrefixPlus }
    var isPrefixOrPlus: Bool { matchType.isPrefixOrPlus }
    var isSubstring: Bool { matchType.isSubstring }
    var isSubstringPlus: Bool { matchType.isSubstringPlus }
    var isSubstringOrPlus: Bool { matchType.isSubtringOrPlus }

    var isCaseSensitive: Bool {
      switch matchType {
      case .prefix(let b, _): return b
      case .prefixPlus(let b, _): return b
      default: return false
      }
    }

    public var description: String {
      "(\(key), \(value), \(matchType), \(score))"
    }

    func with(matchType: MatchSpec) -> Result {
      Result(key: key, value: value, matchType: matchType, score: score)
    }

    func with(score: Int) -> Result {
      Result(key: key, value: value, matchType: matchType, score: score)
    }

    public static func == (lhs: Result, rhs: Result) -> Bool {
      lhs.key == rhs.key && lhs.matchType == rhs.matchType
    }

    public static func < (lhs: Result, rhs: Result) -> Bool {
      if (lhs.isPrefixOrPlus || lhs.isSubstringOrPlus)
        && (rhs.isPrefixOrPlus || rhs.isSubstringOrPlus)
      {
        let leftScore = Double(lhs.score) + (lhs.isCaseSensitive ? 0.5 : 0)
        let rightScore = Double(rhs.score) + (rhs.isCaseSensitive ? 0.5 : 0)
        if leftScore != rightScore {
          return leftScore > rightScore
        }
        else if lhs.matchType != rhs.matchType {
          return lhs.matchType < rhs.matchType
        }
      }
      else {
        if lhs.matchType != rhs.matchType {
          return lhs.matchType < rhs.matchType
        }
        else if lhs.score != rhs.score {
          return lhs.score > rhs.score
        }
      }

      if lhs.key.lowercased() != rhs.key.lowercased() {
        return lhs.key.lowercased() < rhs.key.lowercased()
      }
      else {
        return lhs.key < rhs.key
      }
    }
  }

  public enum MatchSpec: Equatable, Comparable, CustomStringConvertible {
    case prefix(caseSensitive: Bool, length: Int)
    case subString(location: Int, length: Int)

    /// prefix + subsequence match
    case prefixPlus(caseSensitive: Bool, length: Int)
    /// substring + subsequence match
    case subStringPlus(location: Int, length: Int)

    case nGram
    /// n-gram + subsequence match
    case nGramPlus
    case subSequence

    public static func == (lhs: MatchSpec, rhs: MatchSpec) -> Bool {
      lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: MatchSpec, rhs: MatchSpec) -> Bool {
      lhs.rawValue < rhs.rawValue
    }

    var isPrefixOrPlus: Bool {
      switch self {
      case .prefix, .prefixPlus: return true
      default: return false
      }
    }

    var isPrefix: Bool {
      switch self {
      case .prefix: return true
      default: return false
      }
    }

    var isPrefixPlus: Bool {
      switch self {
      case .prefixPlus: return true
      default: return false
      }
    }

    var isSubstring: Bool {
      switch self {
      case .subString: return true
      default: return false
      }
    }

    var isSubstringPlus: Bool {
      switch self {
      case .subStringPlus: return true
      default: return false
      }
    }

    var isSubtringOrPlus: Bool {
      switch self {
      case .subString, .subStringPlus: return true
      default: return false
      }
    }

    private var rawValue: Int {
      switch self {
      case .prefix(let b, _): return b ? 1 : 2
      case .subString: return 3
      case .prefixPlus(let b, _): return b ? 4 : 5
      case .subStringPlus: return 6
      case .nGram: return 7
      case .nGramPlus: return 8
      case .subSequence: return 9
      }
    }

    public var description: String {
      switch self {
      case .prefix(let b): "prefix(\(b))"
      case .subString: "subString"
      case .prefixPlus(let b): "prefixPlus(\(b))"
      case .subStringPlus: "subStringPlus"
      case .nGram: "nGram"
      case .nGramPlus: "nGramPlus"
      case .subSequence: "subSequence"
      }
    }
  }

  private var invertedFile: NGramIndex
  var gramSize: Int { invertedFile.n }

  private var tree: TSTree<Value>

  /// Number of keys.
  var count: Int { tree.count }

  // MARK: - Initialization

  public init(gramSize: Int) {
    self.invertedFile = NGramIndex(n: gramSize)
    self.tree = .init()
  }

  // MARK: - CRUD Operations

  /// Insert list of key-value pairs. In case a key already exists, old value
  /// is replaced.
  public func insert<C: Collection>(contentsOf elements: C) where C.Element == Element {
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
    var quota = maxResults
    var keySet = Set<String>()
    var results = [Result]()

    func addResults(_ phaseResults: [Element], type: MatchSpec) {
      phaseResults.forEach { keySet.insert($0.key) }
      quota -= phaseResults.count

      let phaseResults = phaseResults.map { Result(key: $0, value: $1, matchType: type) }
      results.append(contentsOf: phaseResults)
    }

    // obtain prefix search results
    let prefixResults = prefixSearch(query, maxResults: quota)
    addResults(prefixResults, type: .prefix(caseSensitive: true, length: query.count))

    guard quota > 0 else { return results }

    // obtain n-gram search results
    let nGramResults = nGramSearch(query, maxResults: quota)
      .filter { key, _ in !keySet.contains(key) }
    addResults(nGramResults, type: .nGram)

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
}
