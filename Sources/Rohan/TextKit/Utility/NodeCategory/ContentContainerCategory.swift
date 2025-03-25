// Copyright 2024-2025 Lie Yan

/// The kind of content container an insertion point immediately into this node is in.
struct ContentContainerCategory: OptionSet, CaseIterable {
  let rawValue: Int

  static var allCases: [ContentContainerCategory] {
    [
      .plainTextContainer, .inlineTextContainer, .paragraphContainer,
      .topLevelContainer, .mathList,
    ]
  }

  /// plain text container (for text/math layout)
  /// Example: EmphasisNode
  static let plainTextContainer = ContentContainerCategory(rawValue: 1 << 0)
  /// inline text container (for text layout)
  /// Example: HeadingNode
  static let inlineTextContainer = ContentContainerCategory(rawValue: 1 << 1 | 1 << 0)
  /// paragraph container but not top-level (for text layout)
  /// Example: TableCell
  static let paragraphContainer =
    ContentContainerCategory(rawValue: 1 << 2 | 1 << 1 | 1 << 0)
  /// top level container (for text layout)
  /// Example: RootNode
  static let topLevelContainer =
    ContentContainerCategory(rawValue: 1 << 3 | 1 << 2 | 1 << 1 | 1 << 0)
  /// inline math container (for math layout)
  /// Example: nucleus component, etc.
  static let mathList = ContentContainerCategory(rawValue: 1 << 4 | 1 << 0)
}
