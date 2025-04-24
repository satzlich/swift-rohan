// Copyright 2024-2025 Lie Yan

/// The kind of content container an insertion point is in.
public struct ContainerCategory: OptionSet, Equatable, Hashable, CaseIterable {
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static var allCases: [ContainerCategory] {
    [
      .textContainer, .inlineTextContainer, .paragraphContainer,
      .topLevelContainer, .mathContainer,
    ]
  }

  /// plain text container (for text layout)
  /// Example: EmphasisNode
  static let textContainer = ContainerCategory(rawValue: 1 << 0)

  /// inline text container (for text layout)
  /// Example: HeadingNode
  static let inlineTextContainer = ContainerCategory(rawValue: 1 << 1 | 1 << 0)

  /// paragraph container but not top-level (for text layout)
  /// Example: TableCell
  static let paragraphContainer = ContainerCategory(rawValue: 1 << 2 | 1 << 1 | 1 << 0)

  /// top level container (for text layout)
  /// Example: RootNode
  static let topLevelContainer =
    ContainerCategory(rawValue: 1 << 3 | 1 << 2 | 1 << 1 | 1 << 0)

  /// math container (for math layout)
  /// Example: nucleus component, etc.
  static let mathContainer = ContainerCategory(rawValue: 1 << 4 | 1 << 0)

}

extension ContainerCategory {
  func layoutMode() -> LayoutMode {
    switch self {
    case .mathContainer:
      return .mathMode

    case .textContainer,
      .inlineTextContainer,
      .paragraphContainer,
      .topLevelContainer:
      return .textMode

    default:
      assertionFailure("ContainerCategory value: \(self)")
      return .textMode
    }
  }
}
