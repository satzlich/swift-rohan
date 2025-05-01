// Copyright 2024-2025 Lie Yan

import Foundation

enum CommandBodyV2 {
  /// insert string
  case insertString(InsertString)

  /// insert expressions
  case insertExpressions(InsertExpressions)

  /// add/goto math component
  case addMathComponent(MathIndex)
}

enum CommandPreview {
  case string(String)
  case image(String)  // file name without extension
}

struct InsertString {
  let string: String
  let category: ContentCategory
  let backwardMoves: Int

  init(_ string: String, _ category: ContentCategory, _ backwardMoves: Int = 0) {
    precondition(backwardMoves >= 0)

    self.string = string
    self.category = category
    self.backwardMoves = backwardMoves
  }
}

struct InsertExpressions {
  let expressions: [Expr]
  let category: ContentCategory
  let backwardMoves: Int
  let preview: CommandPreview?

  init(
    _ expressions: [Expr],
    _ category: ContentCategory,
    _ backwardMoves: Int,
    preview: CommandPreview? = nil
  ) {
    precondition(backwardMoves >= 0)

    self.expressions = expressions
    self.category = category
    self.backwardMoves = backwardMoves
    self.preview = preview
  }
}
