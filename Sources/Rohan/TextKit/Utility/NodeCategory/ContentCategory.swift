// Copyright 2024-2025 Lie Yan

enum TextContentCategory {
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
}

enum MathContentCategory {
  /// plain text
  case plaintext

  /// math list content but not plain text
  case mathListContent
}
