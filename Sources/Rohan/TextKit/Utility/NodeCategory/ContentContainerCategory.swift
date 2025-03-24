// Copyright 2024-2025 Lie Yan

/// The kind of content container an insertion point immediately into this node is in.
enum ContentContainerCategory: Int {
  /// plain text container (for text/math layout)
  /// Example: EmphasisNode
  case plainTextContainer = 0

  /// inline text container (for text layout)
  /// Example: HeadingNode
  case inlineTextContainer = 1

  /// paragraph container but not top-level (for text layout)
  /// Example: TableCell
  case paragraphContainer = 2

  /// top level container (for text layout)
  /// Example: RootNode
  case topLevelContainer = 3

  /// inline math container (for math layout)
  /// Example: nucleus component, etc.
  case mathList = 4

  /// Given two content container categories, returns a value so that the result
  /// is the least restricting category that is compatible with both categories.
  static func intersection(
    _ a: ContentContainerCategory, _ b: ContentContainerCategory
  ) -> ContentContainerCategory {
    if a == b {
      return a
    }
    else if a == .mathList || b == .mathList {
      return .plainTextContainer
    }
    else {
      let minValue = min(a.rawValue, b.rawValue)
      return ContentContainerCategory(rawValue: minValue)!
    }
  }
}
