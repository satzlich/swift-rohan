// Copyright 2024-2025 Lie Yan

final class MatrixExpr: ArrayExpr {
  final override class var type: ExprType { .matrix }

  final override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }
}
