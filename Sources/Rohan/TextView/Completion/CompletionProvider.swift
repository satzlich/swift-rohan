// Copyright 2024-2025 Lie Yan

import Foundation
import SatzAlgorithms

public final class CompletionProvider {

  private typealias Result = SearchEngine<CommandRecord>.Result

  private struct CacheKey: Equatable, Hashable {
    let query: String
    let enableFuzzy: Bool

    init(_ query: String, _ enableFuzzy: Bool) {
      self.query = query
      self.enableFuzzy = enableFuzzy
    }
  }

  private let searchEngine: SearchEngine<CommandRecord>
  private let resultCache: TimedCache<CacheKey, Array<Result>>

  public init() {
    self.searchEngine = SearchEngine()
    self.resultCache = TimedCache(expirationInterval: TimeInterval(30))
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
  ) -> [CommandRecord] {
    // if the query is empty, return top K records
    if query.isEmpty {
      var results = getTopK(maxResults, container)
      Self.sortRecords(&results)
      return results
    }

    var results: [Result]
    if let cached = getCachedResults(query, enableFuzzy) {
      results = cached
    }
    else {
      let searched = searchEngine.search(query, maxResults, enableFuzzy)
      if searched.count < maxResults {
        resultCache.setValue(searched, forKey: CacheKey(query, enableFuzzy))
      }
      results = searched
    }

    results.removeAll { result in
      let record = result.value
      return !record.contentCategory.isCompatible(with: container)
    }

    Self.sortResults(&results)
    return results.map(\.value)
  }

  private func getCachedResults(_ query: String, _ enableFuzzy: Bool) -> [Result]? {
    precondition(!query.isEmpty)

    var string = query
    var results: [Result]?
    while string.count >= searchEngine.nGramSize {
      if let cached = resultCache.value(forKey: CacheKey(string, enableFuzzy)) {
        results = cached
        break
      }
      string.removeLast()
    }
    guard let results else { return nil }

    if string.count == query.count {
      return results
    }

    // if the query is not cached, we need to filter the results
    return results.filter { result in
      let record = result.value
      return query.isSubsequence(of: record.name)
    }
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

  /// Sorts the command records based on their names.
  private static func sortRecords(_ records: inout [CommandRecord]) {
    records.sort { lhs, rhs in
      if lhs.name.lowercased() != rhs.name.lowercased() {
        return lhs.name.lowercased() < rhs.name.lowercased()
      }
      else {
        return lhs.name < rhs.name
      }
    }
  }
}
