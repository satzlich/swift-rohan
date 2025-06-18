// Copyright 2024-2025 Lie Yan

public enum ContentCategory: CaseIterable {
  /// plaintext
  case plaintext
  /// plaintext + universal symbols
  case universalText
  /// universal text + text symbols
  case textText
  /// text-text + inline-math
  case extendedText
  /// inline text content
  case inlineContent
  /// a list of ParagraphNode's
  case paragraphNodes
  /// a list of top-level nodes of which at least one is non-ParagraphNode
  case blockNodes
  /// plaintext + math symbols
  case mathText
  /// math-text + other math content
  case mathContent

  var isUniversal: Bool { self == .plaintext || self == .universalText }
  var isPlaintext: Bool { self == .plaintext }
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

  case .universalText:
    return match(
      container, .textTextContainer, .extendedTextContainer, .inlineContentContainer,
      .paragraphContainer, .blockContainer)
      || match(container, .mathTextContainer, .mathContainer)

  case .textText:
    return match(
      container, .textTextContainer, .extendedTextContainer, .inlineContentContainer,
      .paragraphContainer, .blockContainer)

  case .extendedText:
    return match(
      container, .extendedTextContainer, .inlineContentContainer, .paragraphContainer,
      .blockContainer)

  case .inlineContent:
    return match(container, .inlineContentContainer, .paragraphContainer, .blockContainer)

  case .paragraphNodes:
    return match(container, .paragraphContainer, .blockContainer)

  case .blockNodes:
    return container == .blockContainer

  case .mathText:
    return match(container, .mathTextContainer, .mathContainer)

  case .mathContent:
    return container == .mathContainer
  }

  func match<T: Equatable>(_ a: T, _ items: T...) -> Bool { items.contains(a) }
}
