// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import SatzAlgorithms

// TODO: score and sort
// criteria: exact match, prefix match, substring match, n-gram match, subsequence match

public final class CompletionProvider {
  static var gramSize: Int { 2 }

  typealias Result = SearchEngine<CommandRecord>.Result

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

        let keySet = Set(results.map { $0.key })
        let filtered = searched.filter { !keySet.contains($0.key) }

        results.append(contentsOf: filtered)
      }
      results = results.compactMap { Self.refineResult($0, query) }
    }
    else if query.isEmpty {
      let records = getTopK(maxResults, container)
      results = records.compactMap { Self.computeResult($0, query) }
      results.sort()
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
    results.sort()

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

  private static func refineResult(_ result: Result, _ query: String) -> Result? {
    let key = result.key
    let keyLowecased = key.lowercased()
    let queryLowercased = query.lowercased()

    switch result.matchType {
    case .prefix(let caseSensitive, _):
      switch caseSensitive {
      case true:
        if matchPrefix(key, query) {
          return result.with(score: query.count)
        }
        fallthrough

      case false:
        if matchPrefix(keyLowecased, queryLowercased) {
          return result.with(
            matchType: .prefix(caseSensitive: false, length: query.count)
          )
          .with(score: queryLowercased.count)
        }
        else if matchSubSequence(keyLowecased, queryLowercased) {
          return result.with(
            matchType: .prefixPlus(caseSensitive: caseSensitive, length: query.count))
        }
        return nil
      }

    case .prefixPlus(let caseSensitive):
      if matchSubSequence(keyLowecased, queryLowercased) {
        return result
      }
      return nil

    case .subString(let location, let length):
      if matchSubstring(keyLowecased, queryLowercased) {
        return result.with(score: queryLowercased.count)
      }
      else if matchSubSequence(keyLowecased, queryLowercased) {
        return result.with(matchType: .subStringPlus(location: location, length: length))
      }
      return nil

    case .subStringPlus:
      if matchSubSequence(keyLowecased, queryLowercased) {
        return result
      }
      return nil

    case .nGram:
      if matchPrefix(result.key, query) {
        return result.with(matchType: .prefix(caseSensitive: true, length: query.count))
          .with(score: query.count)
      }
      else if matchPrefix(keyLowecased, queryLowercased) {
        return result.with(matchType: .prefix(caseSensitive: false, length: query.count))
          .with(score: queryLowercased.count)
      }
      else if matchSubstring(keyLowecased, queryLowercased) {
        return result.with(matchType: .subString(location: 0, length: 0))
          .with(score: queryLowercased.count)
      }
      else if matchNGram(keyLowecased, queryLowercased) {
        return result.with(matchType: .nGram)
          .with(score: queryLowercased.count)
      }
      else if matchSubSequence(keyLowecased, queryLowercased) {
        return result.with(matchType: .nGramPlus)
      }
      return nil

    case .nGramPlus:
      if matchNGram(keyLowecased, queryLowercased) {
        return result.with(matchType: .nGram)
          .with(score: queryLowercased.count)
      }
      else if matchSubSequence(keyLowecased, queryLowercased) {
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

    if matchPrefix(key, query) {
      return Result(
        key: key, value: record,
        matchType: .prefix(caseSensitive: true, length: query.count),
        score: query.count)
    }

    let keyLowercased = key.lowercased()
    let queryLowercased = query.lowercased()

    if matchPrefix(keyLowercased, queryLowercased) {
      return Result(
        key: key, value: record,
        matchType: .prefix(caseSensitive: false, length: query.count),
        score: queryLowercased.count)
    }
    else if matchSubstring(keyLowercased, queryLowercased) {
      return Result(
        key: key, value: record, matchType: .subString(location: 0, length: query.count),
        score: queryLowercased.count)
    }
    else if matchNGram(keyLowercased, queryLowercased) {
      return Result(
        key: key, value: record, matchType: .nGram, score: queryLowercased.count)
    }
    else if matchSubSequence(keyLowercased, queryLowercased) {
      return Result(key: key, value: record, matchType: .subSequence)
    }
    return nil
  }

  private static func matchPrefix(_ string: String, _ query: String) -> Bool {
    string.hasPrefix(query)
  }

  private static func matchSubstring(_ string: String, _ query: String) -> Bool {
    string.contains(query)
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
