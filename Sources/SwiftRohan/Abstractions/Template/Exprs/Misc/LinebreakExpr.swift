// Copyright 2024-2025 Lie Yan

import Foundation

final class LinebreakExpr: Expr {
  override class var type: ExprType { .linebreak }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(linebreak: self, context)
  }
}
