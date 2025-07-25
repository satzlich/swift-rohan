import Foundation

final class ParListExpr: ElementExpr {
  class override var type: ExprType { .parList }

  override func with(children: Array<Expr>) -> Self {
    Self(children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(parList: self, context)
  }
}
