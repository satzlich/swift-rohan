// Copyright 2024-2025 Lie Yan

import Foundation

public final class CompletionProvider {
  private let engine: SearchEngine<CommandRecord>

  private typealias Result = SearchEngine<CommandRecord>.Result

  public init() {
    self.engine = .init()
  }

  /// Adds a collection of command records to the completion provider.
  /// Each command record is keyed by its name.
  public func addItems(_ records: [CommandRecord]) {
    let records = records.map { record in (record.name, record) }
    engine.insert(contentsOf: records)
  }

  /// Returns the completion for the given query and container.
  func getCompletions(
    _ query: String, _ container: ContainerCategory,
    maxResults: Int = 10, enableFuzzy: Bool = false
  ) -> [CommandRecord] {
    if query.isEmpty {
      var results = getTopK(maxResults, container)
      Self.sortRecords(&results)
      return results
    }
    else {
      var results = engine.search(query, maxResults: maxResults, enableFuzzy: enableFuzzy)
        .filter { $0.value.contentCategory.isCompatible(with: container) }
      Self.sortResults(&results)
      return results.map(\.value)
    }
  }

  /// Returns the top K command records that match the given container category.
  private func getTopK(_ k: Int, _ container: ContainerCategory) -> [CommandRecord] {
    var results = [CommandRecord]()
    results.reserveCapacity(k)

    engine.enumerateElements { record in
      if record.value.contentCategory.isCompatible(with: container) {
        results.append(record.value)
      }
      return results.count < k
    }

    return results
  }

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
