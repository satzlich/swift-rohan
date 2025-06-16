// Copyright 2024-2025 Lie Yan

final class MultilineExpr: ArrayExpr {
  final override class var type: ExprType { .multiline }

  final override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(multiline: self, context)
  }
}
