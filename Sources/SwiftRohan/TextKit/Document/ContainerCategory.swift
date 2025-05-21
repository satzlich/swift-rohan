// Copyright 2024-2025 Lie Yan

/// The kind of content container an insertion point is in.
public struct ContainerCategory: OptionSet, Equatable, Hashable, CaseIterable {
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static var allCases: [ContainerCategory] {
    [
      .textTextContainer, .extendedTextContainer, .inlineContentContainer,
      .paragraphContainer, .topLevelContainer,
      .mathPlaintextContainer, .mathTextContainer, .mathContainer,
    ]
  }

  /// coontainer for text-text-compatible (for text layout)
  static let textTextContainer = ContainerCategory(rawValue: 0b0000_0001)

  /// container for extended-text-compatible (for text layout)
  /// Example: EmphasisNode
  static let extendedTextContainer = ContainerCategory(rawValue: 0b0000_0011)

  /// container for inline-content-compatible (for text layout)
  /// Example: HeadingNode
  static let inlineContentContainer = ContainerCategory(rawValue: 0b0000_0111)

  /// container for paragraph-compatible (for text layout)
  /// Example: TableCell
  static let paragraphContainer = ContainerCategory(rawValue: 0b0000_1111)

  /// container for top-level-compatible (for text layout)
  /// Example: RootNode
  static let topLevelContainer = ContainerCategory(rawValue: 0b0001_1111)

  /// container for plaintext (for math layout)
  static let mathPlaintextContainer = ContainerCategory(rawValue: 0b0010_0000)

  /// container for math-text-compatible (for math layout)
  static let mathTextContainer = ContainerCategory(rawValue: 0b0100_0000)

  /// math container (for math layout)
  /// Example: nucleus component, etc.
  static let mathContainer = ContainerCategory(rawValue: 0b1000_0000)
}

extension ContainerCategory {
  func layoutMode() -> LayoutMode {
    switch self {
    case .textTextContainer,
      .extendedTextContainer,
      .inlineContentContainer,
      .paragraphContainer,
      .topLevelContainer:
      return .textMode

    case .mathPlaintextContainer,
      .mathTextContainer,
      .mathContainer:
      return .mathMode

    default:
      assertionFailure("unknown ContainerCategory: \(self)")
      return .textMode
    }
  }
}
