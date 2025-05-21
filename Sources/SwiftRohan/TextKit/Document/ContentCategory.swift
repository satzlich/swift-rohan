// Copyright 2024-2025 Lie Yan

public enum ContentCategory: CaseIterable {
  /// plaintext for both text and math layout
  case plaintext

  /// plaintext restricted to text layout
  case textText

  /// plaintext restricted to text layout, and inlinemath
  case extendedText

  /// inline text content
  case inlineContent

  /// text content that can be contained in a ParagraphNode, and that contains at
  /// least a block node
  case containsBlock

  /// a list of ParagraphNode's
  case paragraphNodes

  /// a list of top-level nodes of which at least one is non-ParagraphNode
  case topLevelNodes

  /// plaintext restricted to math layout
  case mathText

  /// math content (plain text or other math content)
  case mathContent

  var isUniversal: Bool { self == .plaintext }
  var isTextual: Bool { self == .plaintext || self == .textText || self == .mathText }
  var isMathOnly: Bool { self == .mathText || self == .mathContent }
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

  case .textText:
    return match(
      container, .textTextContainer, .extendedTextContainer, .inlineContentContainer,
      .paragraphContainer, .topLevelContainer)

  case .extendedText:
    return match(
      container, .extendedTextContainer, .inlineContentContainer, .paragraphContainer,
      .topLevelContainer)

  case .inlineContent:
    return match(
      container, .inlineContentContainer, .paragraphContainer, .topLevelContainer)

  case .containsBlock, .paragraphNodes:
    return match(container, .paragraphContainer, .topLevelContainer)

  case .topLevelNodes:
    return container == .topLevelContainer

  case .mathText:
    return match(container, .mathTextContainer, .mathContainer)

  case .mathContent:
    return container == .mathContainer
  }

  func match<T: Equatable>(_ a: T, _ items: T...) -> Bool { items.contains(a) }
}
