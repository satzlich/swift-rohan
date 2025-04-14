// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

public final class SearchEngine<Value> {
  public typealias Element = (key: String, value: Value)

  public struct Result: CustomStringConvertible {
    let key: String
    let value: Value
    let matchType: MatchType

    public var description: String {
      "(\(key), \(value), \(matchType))"
    }

    func with(matchType: MatchType) -> Result {
      Result(key: key, value: value, matchType: matchType)
    }
  }

  public enum MatchType: Int, CustomStringConvertible {
    case prefix = 0
    case prefixMinus = 1
    case nGram = 2
    case subSequence = 3

    public static func < (lhs: MatchType, rhs: MatchType) -> Bool {
      lhs.rawValue < rhs.rawValue
    }

    public var description: String {
      switch self {
      case .prefix: "prefix"
      case .prefixMinus: "prefixMinus"
      case .nGram: "nGram"
      case .subSequence: "subSequence"
      }
    }
  }

  private var nGramIndex: NGramIndex
  var nGramSize: Int { nGramIndex.n }

  private var tree: TSTree<Value>

  /// Number of keys.
  var count: Int { tree.count }

  // MARK: - Initialization

  public init(gramSize: Int) {
    self.nGramIndex = NGramIndex(n: gramSize)
    self.tree = .init()
  }

  // MARK: - CRUD Operations

  /// Insert list of key-value pairs. In case a key already exists, old value
  /// is replaced.
  public func insert<C: Collection>(contentsOf elements: C) where C.Element == Element {
    nGramIndex.addDocuments(elements.lazy.map(\.key))
    elements.shuffled()  // shuffle to improve balance
      .forEach { key, value in tree.insert(key, value) }
  }

  /// Insert key-value pair. If key already exists, old value is replaced.
  /// - Important: Adding keys in alphabetical order results in bad performance.
  ///     Prefer batch insertion with ``insert(contentsOf:)`` for better performance.
  public func insert(_ key: String, value: Value) {
    nGramIndex.addDocument(key)
    tree.insert(key, value)
  }

  /// Delete key (and associated value) from the data set.
  public func delete(_ key: String) {
    nGramIndex.delete(key)
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
    _ query: String, _ maxResults: Int = 10, _ enableFuzzy: Bool = true
  ) -> [Result] {
    var quota = maxResults
    var keySet = Set<String>()
    var results = [Result]()

    func addResults(_ phaseResults: [Element], type: MatchType) {
      phaseResults.forEach { keySet.insert($0.key) }
      quota -= phaseResults.count

      let phaseResults = phaseResults.map { Result(key: $0, value: $1, matchType: type) }
      results.append(contentsOf: phaseResults)
    }

    // obtain prefix search results
    let prefixResults = prefixSearch(query, maxResults: quota)
    addResults(prefixResults, type: .prefix)

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
    nGramIndex.search(query).lazy
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
  public func compact() { nGramIndex.compact() }
}
