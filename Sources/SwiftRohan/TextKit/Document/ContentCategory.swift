// Copyright 2024-2025 Lie Yan

public enum ContentCategory: CaseIterable {
  /// plain text
  case plaintext

  /// inline text content but not plain text
  case inlineContent

  /// text content that can be contained in a ParagraphNode, and that contains at
  /// least a block node
  case containsBlock

  /// a list of ParagraphNode's
  case paragraphNodes

  /// a list of top-level nodes of which at least one is non-ParagraphNode
  case topLevelNodes

  /// math list content but not plain text
  case mathListContent
}

extension ContentCategory {
  @inline(__always)
  func isCompatible(with container: ContainerCategory) -> Bool {
    SwiftRohan.isCompatible(content: self, container)
  }
}

extension ContainerCategory {
  @inline(__always)
  func isCompatible(with content: ContentCategory) -> Bool {
    SwiftRohan.isCompatible(content: content, self)
  }
}

/// Returns true if content is compatible with container.
@inline(__always)
private func isCompatible(
  content: ContentCategory, _ container: ContainerCategory
) -> Bool {
  switch content {
  case .plaintext:
    return true
  case .inlineContent:
    return match(container, .inlineTextContainer, .paragraphContainer, .topLevelContainer)

  case .containsBlock, .paragraphNodes:
    return match(container, .paragraphContainer, .topLevelContainer)

  case .topLevelNodes:
    return container == .topLevelContainer
  case .mathListContent:
    return container == .mathList
  }

  func match<T: Equatable>(_ a: T, _ items: T...) -> Bool {
    for item in items {
      if a == item { return true }
    }
    return false
  }
}
