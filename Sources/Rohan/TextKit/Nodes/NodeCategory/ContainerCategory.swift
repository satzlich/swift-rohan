// Copyright 2024-2025 Lie Yan

/// The kind of content container an insertion point immediately into this node is in.
struct ContainerCategory: OptionSet, CaseIterable {
  let rawValue: Int

  static var allCases: [ContainerCategory] {
    [
      .plainTextContainer, .inlineTextContainer, .paragraphContainer,
      .topLevelContainer, .mathList,
    ]
  }

  /// plain text container (for text/math layout)
  /// Example: EmphasisNode
  static let plainTextContainer = ContainerCategory(rawValue: 1 << 0)
  /// inline text container (for text layout)
  /// Example: HeadingNode
  static let inlineTextContainer = ContainerCategory(rawValue: 1 << 1 | 1 << 0)
  /// paragraph container but not top-level (for text layout)
  /// Example: TableCell
  static let paragraphContainer =
    ContainerCategory(rawValue: 1 << 2 | 1 << 1 | 1 << 0)
  /// top level container (for text layout)
  /// Example: RootNode
  static let topLevelContainer =
    ContainerCategory(rawValue: 1 << 3 | 1 << 2 | 1 << 1 | 1 << 0)
  /// inline math container (for math layout)
  /// Example: nucleus component, etc.
  static let mathList = ContainerCategory(rawValue: 1 << 4 | 1 << 0)
}
