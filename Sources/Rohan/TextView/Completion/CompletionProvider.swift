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
    var shouldCache = false
    var results: [Result]

    if let (source, cached) = getCachedResults(query, container, enableFuzzy) {
      if source.count == query.count {
        return cached
      }
      shouldCache = true
      results = cached

      if source.count == 1 {
        assert(query.count > 1)
        let searched = searchEngine.search(query, maxResults, enableFuzzy)

        shouldCache = searched.count < maxResults
        results = Self.mergeResults(results, searched)
      }
      results = results.compactMap { Self.refineResult($0, query) }
    }
    else if query.isEmpty {
      let records = getTopK(maxResults, container)
      results = records.compactMap { Self.computeResult($0, query) }
      Self.sortResults(&results)
      if records.count < maxResults {
        let key = CacheKey(query, container, enableFuzzy)
        resultCache.setValue(results, forKey: key)
      }
      return results
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

    if shouldCache {
      let key = CacheKey(query, container, enableFuzzy)
      resultCache.setValue(results, forKey: key)
    }

    return results
  }

  private func getCachedResults(
    _ query: String, _ container: ContainerCategory, _ enableFuzzy: Bool
  ) -> (source: String, Array<Result>)? {
    // obtain the cached results for the query
    do {
      let key = CacheKey(query, container, enableFuzzy)
      if let cached = resultCache.value(forKey: key) {
        return (query, cached)
      }
    }
    guard !query.isEmpty else { return nil }

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
    return results.map { (string, $0) }
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
    let keyLowecased = result.key.lowercased()
    let queryLowercased = query.lowercased()

    switch result.matchType {
    case .prefix:
      if matchPrefix(result.key, query) {
        return result
      }
      else if matchSubSequence(keyLowecased, queryLowercased) {
        return result.with(matchType: .prefixMinus)
      }
      return nil

    case .prefixMinus:
      if queryLowercased.isSubsequence(of: keyLowecased) {
        return result.with(matchType: .prefixMinus)
      }
      return nil

    case .nGram:
      if matchPrefix(result.key, query) {
        return result.with(matchType: .prefix)
      }
      else if matchPrefix(keyLowecased, queryLowercased) {
        return result.with(matchType: .prefixMinus)
      }
      else if matchNGram(keyLowecased, queryLowercased) {
        return result.with(matchType: .nGramMinus)
      }
      else if matchSubSequence(keyLowecased, queryLowercased) {
        return result.with(matchType: .nGramMinus)
      }
      return nil

    case .nGramMinus:
      if matchSubSequence(keyLowecased, queryLowercased) {
        return result
      }
      return nil

    case .subSequence:
      if matchSubSequence(keyLowecased, queryLowercased) {
        return result
      }
      return nil
    }
  }

  private static func computeResult(_ record: CommandRecord, _ query: String) -> Result? {
    let key = record.name
    let keyLowecased = key.lowercased()
    let queryLowercased = query.lowercased()

    if matchPrefix(key, query) {
      return Result(key: key, value: record, matchType: .prefix)
    }
    else if matchPrefix(keyLowecased, queryLowercased) {
      return Result(key: key, value: record, matchType: .prefixMinus)
    }
    else if matchNGram(keyLowecased, queryLowercased) {
      return Result(key: key, value: record, matchType: .nGram)
    }
    else if matchSubSequence(keyLowecased, queryLowercased) {
      return Result(key: key, value: record, matchType: .subSequence)
    }
    return nil
  }

  private static func mergeResults(_ a: [Result], _ b: [Result]) -> [Result] {
    var (c, d) = a.count > b.count ? (a, b) : (b, a)
    c.reserveCapacity(a.count + b.count)

    let keySet = Set(c.map { $0.key })
    for result in d {
      if !keySet.contains(result.key) {
        c.append(result)
      }
    }
    return c
  }

  private static func matchPrefix(_ string: String, _ query: String) -> Bool {
    string.hasPrefix(query)
  }

  private static func matchNGram(_ string: String, _ query: String) -> Bool {
    let keyGrams = Satz.nGrams(of: string, n: Self.gramSize)
    let queryGrams = Satz.nGrams(of: query, n: Self.gramSize)
    return queryGrams.isSubsequence(of: keyGrams)
  }

  private static func matchSubSequence(_ string: String, _ query: String) -> Bool {
    query.isSubsequence(of: string)
  }
}
