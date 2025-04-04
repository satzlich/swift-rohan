// Copyright 2024-2025 Lie Yan

import Foundation

public final class RhCompletionProvider {
  private let engine: SearchEngine<CommandRecord>

  public init() {
    self.engine = .init()
  }

  /// Returns the completion for the given query and container.
  public func getCompletions(
    _ query: String, _ container: ContainerCategory,
    maxResults: Int = 10, enableFuzzy: Bool = false
  ) -> [CommandRecord] {
    let results = engine.search(query, maxResults: maxResults, enableFuzzy: enableFuzzy)
      .filter { record in
        record.value.contentCategory.isCompatible(with: container)
      }

    // TODO: sort by relevance

    return results.map(\.value)
  }
}
