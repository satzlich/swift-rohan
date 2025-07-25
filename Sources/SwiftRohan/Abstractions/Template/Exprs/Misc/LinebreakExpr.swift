import Foundation

final class LinebreakExpr: Expr {
  override class var type: ExprType { .linebreak }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(linebreak: self, context)
  }
}
