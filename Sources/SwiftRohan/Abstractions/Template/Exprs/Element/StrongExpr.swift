// Copyright 2024-2025 Lie Yan

final class StrongExpr: ElementExpr {
  class override var type: ExprType { .strong }

  override func with(children: Array<Expr>) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(strong: self, context)
  }
}
