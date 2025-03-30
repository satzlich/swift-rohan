// Copyright 2024-2025 Lie Yan

enum ContentCategory {
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

  @inline(__always)
  func isCompatible(with container: ContainerCategory) -> Bool {
    Rohan.isCompatible(content: self, container)
  }
}

/// Returns true if content is compatible with container.
private func isCompatible(
  content: ContentCategory, _ container: ContainerCategory
) -> Bool {
  switch content {
  case .plaintext:
    return true
  case .inlineContent:
    return [
      .inlineTextContainer, .paragraphContainer, .topLevelContainer,
    ].contains(container)
  case .containsBlock, .paragraphNodes:
    return [.paragraphContainer, .topLevelContainer].contains(container)
  case .topLevelNodes:
    return container == .topLevelContainer
  case .mathListContent:
    return container == .mathList
  }
}
