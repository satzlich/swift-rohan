// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

final class CompletionEngine<Value: Hashable> {
  typealias Element = (key: String, value: Value)

  private var nGramIndex: NGramIndex
  var nGramSize: Int { nGramIndex.n }

  private var tsTree: TSTree<Element>

  /// Number of keys.
  var count: Int { tsTree.count }

  // MARK: - Initialization

  public init(nGramSize n: Int = 2) {
    self.nGramIndex = NGramIndex(n: n)
    self.tsTree = TSTree()
  }

  // MARK: - CRUD Operations

  /// Insert list of key-value pairs. In case a key already exists, old value
  /// is replaced.
  public func insert<C: Collection>(contentsOf elements: C) where C.Element == Element {
    nGramIndex.addDocuments(elements.lazy.map(\.key))
    elements.shuffled()  // shuffle to improve balance
      .forEach { key, value in tsTree.insert(key.lowercased(), (key, value)) }
  }

  /// Insert key-value pair. If key already exists, old value is replaced.
  /// - Important: Adding keys in alphabetical order results in bad performance.
  ///     Prefer batch insertion with ``insert(contentsOf:)`` for better performance.
  public func insert(_ key: String, value: Value) {
    nGramIndex.addDocument(key)
    tsTree.insert(key.lowercased(), (key, value))
  }

  /// Delete key (and associated value) from the data set.
  public func delete(_ key: String) {
    nGramIndex.delete(key)
    tsTree.delete(key.lowercased())
  }

  /// Update the value associated with key.
  public func update(_ key: String, newValue: Value) {
    delete(key)
    insert(key, value: newValue)
  }

  // MARK: - Query Operations

  public func provideCompletions(
    for query: String, maxResults: Int = 10, enableFuzzy: Bool = true
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
      .filter { key, value in !results.contains { $0.key == key } }
    addResults(nGramResults, type: .ngram)

    guard quota > 0, enableFuzzy else { return results }

    // obtain subsequence search results
    let fuzzyResults = fuzzySearch(query, maxResults: quota)
      .filter { key, value in !results.contains { $0.key == key } }
    addResults(fuzzyResults, type: .subsequence)

    return results
  }

  /// Prefix match
  private func prefixSearch(_ query: String, maxResults: Int) -> [Element] {
    guard query.count >= 1 else { return [] }
    return tsTree.search(withPrefix: query.lowercased(), maxResults: maxResults)
      .compactMap { key in tsTree.get(key) }
  }

  /// N-Gram match
  private func nGramSearch(_ query: String, maxResults: Int) -> [Element] {
    nGramIndex.search(query).lazy
      .compactMap({ key in self.tsTree.get(key.lowercased()) })
      .prefix(maxResults)
      .map { $0 }
  }

  /// Subsequence match
  private func fuzzySearch(_ query: String, maxResults: Int) -> [Element] {
    var matches: [Element] = []
    tsTree.enumerateKeysAndValues { key, element in
      guard query.lowercased().isSubsequence(of: key.lowercased())
      else { return true }
      matches.append(element)
      return matches.count < maxResults
    }
    return matches.sorted { $0.key.count < $1.key.count }
  }

  // MARK: - Maintenance

  /// Clear zombie elements resulted from deletions.
  public func compact() { nGramIndex.compact() }

  // MARK: - Result Type

  struct Result: CustomStringConvertible {
    let key: String
    let value: Value
    let matchType: MatchType

    var description: String {
      "(\(key), \(value), \(matchType))"
    }
  }

  enum MatchType: CustomStringConvertible {
    case prefix  // Highest priority
    case ngram  // Middle priority
    case subsequence  // Fallback

    var description: String {
      switch self {
      case .prefix: "prefix"
      case .ngram: "ngram"
      case .subsequence: "subsequence"
      }
    }
  }
}
