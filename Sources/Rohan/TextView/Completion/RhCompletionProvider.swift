// Copyright 2024-2025 Lie Yan

import Foundation

public final class RhCompletionProvider {
  private let engine: SearchEngine<CommandRecord>

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
    if query.isEmpty { return getTopK(maxResults, container) }

    let results = engine.search(query, maxResults: maxResults, enableFuzzy: enableFuzzy)
      .filter { record in
        record.value.contentCategory.isCompatible(with: container)
      }

    return results.map(\.value)
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
}
