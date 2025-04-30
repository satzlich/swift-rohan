// Copyright 2024-2025 Lie Yan

import Foundation

final class TextModeExpr: ElementExpr {
  class override var type: ExprType { .textMode }
  override func with(children: [Expr]) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(textMode: self, context)
  }
}
