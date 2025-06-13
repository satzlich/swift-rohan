// Copyright 2024-2025 Lie Yan

import Foundation

enum NanoUtils {
  /// Count expressions in the given trees where predicate is satisfied.
  static func countExpr(
    from expressions: Array<Expr>, where predicate: @escaping (Expr) -> Bool
  ) -> Int {
    let visitor = CountingExpressionWalker(predicate: predicate)
    expressions.forEach { $0.accept(visitor, ()) }
    return visitor.counter
  }
}

private final class CountingExpressionWalker: ExpressionWalker<Void> {
  private(set) var counter = 0
  let predicate: (Expr) -> Bool

  init(predicate: @escaping (Expr) -> Bool) {
    self.predicate = predicate
  }

  override func willVisitExpression(_ expression: Expr, _ context: Void) {
    if predicate(expression) {
      counter += 1
    }
  }
}
