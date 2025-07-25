final class ContentExpr: ElementExpr {
  class override var type: ExprType { .content }

  override func with(children: Array<Expr>) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(content: self, context)
  }
}
