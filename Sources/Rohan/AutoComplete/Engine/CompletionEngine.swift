// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

final class CompletionEngine<Value: Hashable> {
  typealias Element = (key: String, value: Value)

  // Data Structures
  private var prefixTree: TSTree<Value>
  private var ngramIndex: NGramIndex
  private let minPrefixLength: Int

  // User feedback records
  private var selectionCounts: [String: Int] = [:]
  private var lastSelected: [String: Date] = [:]

  public var count: Int { prefixTree.count }

  // MARK: - Initialization

  public init(
    nGramSize n: Int = 2,
    caseSensitive: Bool = false,
    minPrefixLength: Int = 2
  ) {
    self.prefixTree = TSTree()
    self.ngramIndex = NGramIndex(n: n, caseSensitive: caseSensitive)
    self.minPrefixLength = minPrefixLength
  }

  // MARK: - CRUD Operations

  /// Insert list of key-value pairs. In case a key already exists, old value
  /// is replaced.
  public func insert<S: Sequence>(contentsOf elements: S) where S.Element == Element {
    ngramIndex.addDocuments(elements.lazy.map(\.key))
    elements.shuffled()  // shuffle to improve balance
      .forEach { prefixTree.insert($0, $1) }
  }

  /// Insert key-value pair. If key already exists, old value is replaced.
  /// - Important: Adding keys in alphabetical order results in bad performance.
  ///     Prefer batch insertion with ``insert(contentsOf:)`` for better performance.
  public func insert(_ key: String, value: Value) {
    prefixTree.insert(key, value)
    ngramIndex.addDocument(key)
  }

  /// Delete key (and associated value) from the data set.
  public func delete(_ key: String) {
    prefixTree.delete(key)
    ngramIndex.delete(key)
  }

  public func update(_ key: String, newValue: Value) {
    delete(key)
    insert(key, value: newValue)
  }

  // MARK: - Query Operations

  public func search(
    _ query: String, maxResults: Int = 10, enableFuzzy: Bool = true
  ) -> [Element] {
    return []
  }

  /// Prefix match
  private func prefixSearch(_ query: String, maxResults: Int) -> [(String, Value)] {
    guard query.count >= minPrefixLength else { return [] }
    return prefixTree.search(withPrefix: query, maxResults: maxResults)
      .compactMap { key in prefixTree.get(key).map { (key, $0) } }
  }

  /// N-Gram match
  private func ngramSearch(_ query: String, maxResults: Int) -> [(String, Value)] {
    ngramIndex.search(query)
      .lazy
      .compactMap({ key in self.prefixTree.get(key).map { (key, $0) } })
      .prefix(maxResults)
      .map { $0 }
  }

  /// Subsequence match
  private func fuzzySearch(_ query: String, maxResults: Int) -> [(String, Value)] {
    let query = query.lowercased()
    var matches: [Element] = []
    prefixTree.enumerateKeysAndValues { key, value in
      if isOrderedSubsequence(query, in: key.lowercased()) {
        matches.append((key, value))
        return matches.count < maxResults
      }
      return true
    }
    return matches.sorted { $0.key.count < $1.key.count }  // Prefer shorter matches
  }

  // MARK: - Rank

  private func rank(
    _ results: [Element], query: String
  ) -> [(key: String, value: Value, score: Double)] {
    results.map { item in
      let baseScore = baseMatchScore(item.key, query: query)
      let usageScore = usageBasedScore(item.key)
      return (item.key, item.value, baseScore * usageScore)
    }.sorted { $0.score > $1.score }
  }

  private func baseMatchScore(_ key: String, query: String) -> Double {
    // Prefix matches
    if key.hasPrefix(query) {
      return 2.0
    }
    // Ngram
    else if isOrderedNGrams(query, in: key, n: ngramIndex.n) {
      return 1.5
    }
    // Fuzzy
    else {
      return 1.0
    }
  }

  private func usageBasedScore(_ key: String) -> Double {
    let countWeight = log10(Double((selectionCounts[key] ?? 0) + 1))
    let timeWeight =
      lastSelected[key].map { date in
        1.5 - min(1.0, Date().timeIntervalSince(date) / 3600)
      } ?? 1.0
    return countWeight * timeWeight
  }

  // MARK: - Record User Selection

  /// Call this when user selects a completion
  public func recordSelection(_ key: String) {
    selectionCounts[key, default: 0] += 1
    lastSelected[key] = Date()
  }

  public func resetUserHistory() {
    selectionCounts.removeAll()
    lastSelected.removeAll()
  }

  public func forget(_ key: String) {
    selectionCounts.removeValue(forKey: key)
    lastSelected.removeValue(forKey: key)
  }

  // MARK: - Maintenance

  /// Clear zombie elements resulted from deletions.
  public func compact() { ngramIndex.compact() }
}

private func isOrderedSubsequence(_ query: String, in text: String) -> Bool {
  var queryIndex = query.startIndex

  for char in text {
    guard queryIndex < query.endIndex else { break }
    if char == query[queryIndex] {
      queryIndex = query.index(after: queryIndex)
    }
  }
  return queryIndex == query.endIndex
}

/// Returns true if the n-grams of query occurs in sequential order in the n-grams
/// of text.
private func isOrderedNGrams(_ query: String, in text: String, n: Int) -> Bool {
  precondition(n >= 2)
  let queryGrams = Satz.nGrams(of: query, n: n)
  let textGrams = Satz.nGrams(of: text, n: n)

  var queryIndex = 0
  for textGram in textGrams {
    if queryIndex < queryGrams.count && textGram == queryGrams[queryIndex] {
      queryIndex += 1
    }
  }
  return queryIndex == queryGrams.count
}
