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

    switch result.matchSpec {
    case .prefix(let caseSensitive, let oldLength):
      switch caseSensitive {
      case true:
        if matchPrefix(key, query) {
          return result.with(
            matchType: .prefix(caseSensitive: true, length: query.length))
        }
        fallthrough

      case false:
        if matchPrefix(keyLowecased, queryLowercased) {
          return result.with(
            matchType: .prefix(caseSensitive: false, length: query.length))
        }
        else if matchSubSequence(keyLowecased, queryLowercased) {
          return result.with(
            matchType: .prefixPlus(caseSensitive: false, length: oldLength))
        }
        return nil
      }

    case .prefixPlus(let caseSensitive):
      if matchSubSequence(keyLowecased, queryLowercased) {
        return result
      }
      return nil

    case .subString(let loc, let len):
      if let (location, length) = matchSubstring(keyLowecased, queryLowercased) {
        return result.with(
          matchType: .subString(location: location, length: length))
      }
      else if matchSubSequence(keyLowecased, queryLowercased) {
        return result.with(matchType: .subStringPlus(location: loc, length: len))
      }
      return nil

    case .subStringPlus:
      if matchSubSequence(keyLowecased, queryLowercased) {
        return result
      }
      return nil

    case .nGram(let length):
      if matchPrefix(result.key, query) {
        return result.with(matchType: .prefix(caseSensitive: true, length: query.length))
      }
      else if matchPrefix(keyLowecased, queryLowercased) {
        return result.with(
          matchType: .prefix(caseSensitive: false, length: queryLowercased.length))
      }
      else if let (loc, len) = matchSubstring(keyLowecased, queryLowercased) {
        return result.with(matchType: .subString(location: loc, length: len))
      }
      else if matchNGram(keyLowecased, queryLowercased) {
        return result.with(matchType: .nGram(length: queryLowercased.length))
      }
      else if matchSubSequence(keyLowecased, queryLowercased) {
        return result.with(matchType: .nGramPlus(length: length))
      }
      return nil

    case .nGramPlus(let length):
      if matchNGram(keyLowecased, queryLowercased) {
        return result.with(matchType: .nGram(length: length))
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
        matchSpec: .prefix(caseSensitive: true, length: query.length))
    }

    let keyLowercased = key.lowercased()
    let queryLowercased = query.lowercased()

    if matchPrefix(keyLowercased, queryLowercased) {
      return Result(
        key: key, value: record,
        matchSpec: .prefix(caseSensitive: false, length: query.length))
    }
    else if let (location, length) = matchSubstring(keyLowercased, queryLowercased) {
      return Result(
        key: key, value: record,
        matchSpec: .subString(location: location, length: length))
    }
    else if matchNGram(keyLowercased, queryLowercased) {
      return Result(
        key: key, value: record, matchSpec: .nGram(length: queryLowercased.length))
    }
    else if matchSubSequence(keyLowercased, queryLowercased) {
      return Result(key: key, value: record, matchSpec: .subSequence)
    }
    return nil
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

  private static func matchSubstring(
    _ string: String, _ query: String
  ) -> (location: Int, length: Int)? {
    guard let range = string.range(of: query) else { return nil }
    let location = string.utf16.distance(from: string.startIndex, to: range.lowerBound)
    let length = string.utf16.distance(from: range.lowerBound, to: range.upperBound)
    return (location, length)
  }
}
