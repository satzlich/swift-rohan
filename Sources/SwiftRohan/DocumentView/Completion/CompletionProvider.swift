import Algorithms
import Foundation
import SatzAlgorithms

public final class CompletionProvider {
  static var gramSize: Int { 2 }

  typealias Result = SearchEngine<CommandRecord>.Result
  typealias MatchSpec = SearchEngine<CommandRecord>.MatchSpec

  private struct CacheKey: Equatable, Hashable {
    let query: String
    let container: ContainerProperty
    let enableFuzzy: Bool

    init(_ query: String, _ container: ContainerProperty, _ enableFuzzy: Bool) {
      self.query = query
      self.container = container
      self.enableFuzzy = enableFuzzy
    }
  }

  private let searchEngine: SearchEngine<CommandRecord>
  private let resultCache: TimedCache<CacheKey, Array<Result>>

  public init() {
    self.searchEngine = SearchEngine(gramSize: Self.gramSize)
    self.resultCache = TimedCache(TimeInterval(300))
  }

  /// Adds a collection of command records to the completion provider.
  /// Each command record is keyed by its name.
  public func addItems(_ records: Array<CommandRecord>) {
    let records = records.map { record in (record.name, record) }
    searchEngine.insert(contentsOf: records)
  }

  /// Returns the completion for the given query and container.
  func getCompletions(
    _ query: String, _ container: ContainerProperty,
    _ maxResults: Int, _ enableFuzzy: Bool = false
  ) -> Array<Result> {
    var shouldCache = false
    var results: Array<Result>

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
        let filtered = searched.lazy.filter { !keySet.contains($0.key) }
        results.append(contentsOf: filtered)
      }
      results = results.compactMap { Self.refineResult($0, query) }
    }
    else if query.isEmpty {
      let records = getTopK(maxResults, container)
      shouldCache = records.count < maxResults

      results = records.compactMap { Self.computeResult($0, query) }
      results.sort()

      if shouldCache {
        let key = CacheKey(query, container, enableFuzzy)
        resultCache.setValue(results, forKey: key)
      }
      return results
    }
    else {
      let searched = searchEngine.search(query, maxResults, enableFuzzy)
      shouldCache = searched.count < maxResults
      results = searched.compactMap { Self.refineResult($0, query) }
    }

    results.removeAll { result in
      let command = result.value
      return command.body.isCompatible(with: container) == false
    }
    results.sort()

    if shouldCache {
      let key = CacheKey(query, container, enableFuzzy)
      resultCache.setValue(results, forKey: key)
    }

    return results
  }

  private func getCachedResults(
    _ query: String, _ container: ContainerProperty, _ enableFuzzy: Bool
  ) -> (source: String, Array<Result>)? {
    // Check the cache for the exact match first.
    do {
      let key = CacheKey(query, container, enableFuzzy)
      if let cached = resultCache.value(forKey: key) {
        return (query, cached)
      }
    }

    guard !query.isEmpty else { return nil }

    var string = query
    string.removeLast()

    var results: Array<Result>?
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
  private func getTopK(_ k: Int, _ container: ContainerProperty) -> Array<CommandRecord> {
    var results = Array<CommandRecord>()
    results.reserveCapacity(k)

    searchEngine.enumerateElements { element in
      let command = element.value
      if command.body.isCompatible(with: container) {
        results.append(command)
      }
      return results.count < k
    }

    return results
  }

  /// Refine the result using the query.
  /// - Precondition: the result is obtained from a prefix of the query.
  private static func refineResult(_ result: Result, _ query: String) -> Result? {
    let key = result.key
    let kk = key.lowercased()
    let qq = query.lowercased()

    switch result.matchSpec {
    case .equal(let caseSensitive, let length),
      .prefix(let caseSensitive, let length):

      switch caseSensitive {
      case true:
        if matchPrefix(key, pattern: query) {
          let matchSpec: MatchSpec =
            key.length == query.length
            ? .equal(caseSensitive: true, length: query.length)
            : .prefix(caseSensitive: true, length: query.length)
          return result.with(matchSpec: matchSpec)
        }
        else if matchPrefix(kk, pattern: qq) {
          let matchSpec: MatchSpec =
            kk.length == qq.length
            ? .equal(caseSensitive: false, length: qq.length)
            : .prefix(caseSensitive: false, length: qq.length)
          return result.with(matchSpec: matchSpec)
        }
        else if matchSubSequence(kk, pattern: qq) {
          let matchSpec = MatchSpec.prefixPlus(caseSensitive: true, length: length)
          return result.with(matchSpec: matchSpec)
        }
        return nil

      case false:
        if matchPrefix(kk, pattern: qq) {
          let matchSpec: MatchSpec =
            kk.count == qq.count
            ? .equal(caseSensitive: false, length: qq.length)
            : .prefix(caseSensitive: false, length: qq.length)
          return result.with(matchSpec: matchSpec)
        }
        else if matchSubSequence(kk, pattern: qq) {
          let matchSpec = MatchSpec.prefixPlus(caseSensitive: false, length: length)
          return result.with(matchSpec: matchSpec)
        }
        return nil
      }

    case .prefixPlus:
      if matchSubSequence(kk, pattern: qq) {
        return result
      }
      return nil

    case .subString(let location, let length):
      if let (loc, len) = matchSubstring(kk, pattern: qq) {
        let matchSpec = MatchSpec.subString(location: loc, length: len)
        return result.with(matchSpec: matchSpec)
      }
      else if matchSubSequence(kk, pattern: qq) {
        let matchSpec = MatchSpec.subStringPlus(location: location, length: length)
        return result.with(matchSpec: matchSpec)
      }
      return nil

    case .subStringPlus:
      if matchSubSequence(kk, pattern: qq) {
        return result
      }
      return nil

    case .nGram(let length):
      // the condition may be triggered when maxResults is small.
      // But we cannot construct a test case for this yet.
      if matchPrefix(result.key, pattern: query) {
        let matchSpec = MatchSpec.prefix(caseSensitive: true, length: query.length)
        return result.with(matchSpec: matchSpec)
      }
      else if matchPrefix(kk, pattern: qq) {
        let matchSpec = MatchSpec.prefix(caseSensitive: false, length: qq.length)
        return result.with(matchSpec: matchSpec)
      }
      else if let (loc, len) = matchSubstring(kk, pattern: qq) {
        return result.with(matchSpec: .subString(location: loc, length: len))
      }
      else if matchNGram(kk, pattern: qq) {
        return result.with(matchSpec: .nGram(length: qq.length))
      }
      else if matchSubSequence(kk, pattern: qq) {
        return result.with(matchSpec: .nGramPlus(length: length))
      }
      return nil

    case .nGramPlus:
      if matchSubSequence(kk, pattern: qq) {
        return result
      }
      return nil

    case .subSequence:
      if matchSubSequence(kk, pattern: qq) {
        return result
      }
      return nil
    }
  }

  /// Compute matching result from scratch.
  private static func computeResult(_ record: CommandRecord, _ query: String) -> Result? {
    let key = record.name

    if matchPrefix(key, pattern: query) {
      let matchSpec: MatchSpec =
        key.length == query.length
        ? .equal(caseSensitive: true, length: query.length)
        : .prefix(caseSensitive: true, length: query.length)
      return Result(key: key, value: record, matchSpec: matchSpec)
    }

    let kk = key.lowercased()
    let qq = query.lowercased()

    if matchPrefix(kk, pattern: qq) {
      let matchSpec: MatchSpec =
        kk.length == qq.length
        ? .equal(caseSensitive: false, length: qq.length)
        : .prefix(caseSensitive: false, length: qq.length)
      return Result(key: key, value: record, matchSpec: matchSpec)
    }
    else if let (location, length) = matchSubstring(kk, pattern: qq) {
      let matchSpec = MatchSpec.subString(location: location, length: length)
      return Result(key: key, value: record, matchSpec: matchSpec)
    }
    else if matchNGram(kk, pattern: qq) {
      let matchSpec = MatchSpec.nGram(length: qq.length)
      return Result(key: key, value: record, matchSpec: matchSpec)
    }
    else if matchSubSequence(kk, pattern: qq) {
      return Result(key: key, value: record, matchSpec: .subSequence)
    }
    return nil
  }

  // MARK: - kinds of matching

  private static func matchPrefix(_ string: String, pattern: String) -> Bool {
    string.hasPrefix(pattern)
  }

  private static func matchSubstring(
    _ string: String, pattern: String
  ) -> (location: Int, length: Int)? {
    guard let range = string.range(of: pattern) else { return nil }
    let location = string.utf16.distance(from: string.startIndex, to: range.lowerBound)
    let length = string.utf16.distance(from: range.lowerBound, to: range.upperBound)
    return (location, length)
  }

  private static func matchNGram(_ string: String, pattern: String) -> Bool {
    let keyGrams = Satz.nGrams(of: string, n: Self.gramSize)
    let queryGrams = Satz.nGrams(of: pattern, n: Self.gramSize)
    return queryGrams.isSubsequence(of: keyGrams)
  }

  private static func matchSubSequence(_ string: String, pattern: String) -> Bool {
    pattern.isSubsequence(of: string)
  }

}
