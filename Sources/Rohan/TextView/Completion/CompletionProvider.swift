// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import SatzAlgorithms

public final class CompletionProvider {

  typealias Result = SearchEngine<CommandRecord>.Result
  static var gramSize: Int { 2 }

  private struct CacheKey: Equatable, Hashable {
    let query: String
    let container: ContainerCategory
    let enableFuzzy: Bool

    init(_ query: String, _ container: ContainerCategory, _ enableFuzzy: Bool) {
      self.query = query
      self.container = container
      self.enableFuzzy = enableFuzzy
    }
  }

  private let searchEngine: SearchEngine<CommandRecord>
  private let resultCache: TimedCache<CacheKey, Array<Result>>

  public init() {
    self.searchEngine = SearchEngine(gramSize: Self.gramSize)
    self.resultCache = TimedCache(expirationInterval: TimeInterval(300))
  }

  /// Adds a collection of command records to the completion provider.
  /// Each command record is keyed by its name.
  public func addItems(_ records: [CommandRecord]) {
    let records = records.map { record in (record.name, record) }
    searchEngine.insert(contentsOf: records)
  }

  /// Returns the completion for the given query and container.
  func getCompletions(
    _ query: String, _ container: ContainerCategory,
    _ maxResults: Int, _ enableFuzzy: Bool = false
  ) -> [Result] {
    // if the query is empty, return top K records
    if query.isEmpty {
      var records = getTopK(maxResults, container)
      var results = records.map { record in
        Result(key: record.name, value: record, matchType: .subSequence)
      }
      Self.sortResults(&results)

      if records.count < maxResults {
        let key = CacheKey(query, container, enableFuzzy)
        resultCache.setValue(results, forKey: key)
      }

      return results
    }

    var results: [Result]
    var shouldCache = false
    if let cached = getCachedResults(query, container, enableFuzzy) {
      results = cached
      shouldCache = true
    }
    else {
      let searched = searchEngine.search(query, maxResults, enableFuzzy)
      results = searched.compactMap { Self.refineResult($0, query) }
      shouldCache = searched.count < maxResults
    }

    results.removeAll { result in
      let record = result.value
      return record.contentCategory.isCompatible(with: container) == false
    }

    Self.sortResults(&results)

    if query.count >= searchEngine.nGramSize,
      shouldCache
    {
      let key = CacheKey(query, container, enableFuzzy)
      resultCache.setValue(results, forKey: key)
    }

    return results
  }

  private func getCachedResults(
    _ query: String, _ container: ContainerCategory, _ enableFuzzy: Bool
  ) -> [Result]? {
    precondition(!query.isEmpty)

    // obtain the cached results for the query
    do {
      let key = CacheKey(query, container, enableFuzzy)
      if let cached = resultCache.value(forKey: key) {
        return cached
      }
    }

    // if not found, try to find the cached results by removing one character
    var string = query
    string.removeLast()
    var results: [Result]?
    while true {
      let key = CacheKey(string, container, enableFuzzy)
      if let cached = resultCache.value(forKey: key) {
        results = cached
        break
      }
      if string.isEmpty { break }
      string.removeLast()
    }
    guard let results else { return nil }

    return results.compactMap { Self.refineResult($0, query) }
  }

  /// Returns the top K command records that match the given container category.
  private func getTopK(_ k: Int, _ container: ContainerCategory) -> [CommandRecord] {
    var results = [CommandRecord]()
    results.reserveCapacity(k)

    searchEngine.enumerateElements { record in
      if record.value.contentCategory.isCompatible(with: container) {
        results.append(record.value)
      }
      return results.count < k
    }

    return results
  }

  /// Sorts the results based on match type and key.
  private static func sortResults(_ results: inout [Result]) {
    results.sort { lhs, rhs in
      if lhs.matchType != rhs.matchType {
        return lhs.matchType < rhs.matchType
      }
      else if lhs.key.lowercased() != rhs.key.lowercased() {
        return lhs.key.lowercased() < rhs.key.lowercased()
      }
      else {
        return lhs.key < rhs.key
      }
    }
  }

  private static func refineResult(_ result: Result, _ query: String) -> Result? {
    if result.key.hasPrefix(query) {
      return result.with(matchType: .prefix)
    }

    let keyLowecased = result.key.lowercased()
    let queryLowercased = query.lowercased()

    if keyLowecased.hasPrefix(queryLowercased) {
      return result.with(matchType: .prefixIgnoreCase)
    }

    let keyGrams = Satz.nGrams(of: keyLowecased, n: Self.gramSize)
    let queryGrams = Satz.nGrams(of: queryLowercased, n: Self.gramSize)
    if queryGrams.isSubsequence(of: keyGrams) {
      return result.with(matchType: .nGram)
    }
    if queryLowercased.isSubsequence(of: keyLowecased) {
      return result.with(matchType: .subSequence)
    }
    return nil
  }
}
