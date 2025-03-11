// Copyright 2024-2025 Lie Yan

import Foundation

extension Nano {
  /** Count expressions in the given trees where predicate is satisfied. */
  static func countExpr(
    from expressions: [RhExpr], where predicate: @escaping (RhExpr) -> Bool
  ) -> Int {
    let visitor = CountingExpressionWalker(predicate: predicate)
    expressions.forEach { $0.accept(visitor, ()) }
    return visitor.counter
  }
}

private final class CountingExpressionWalker: ExpressionWalker<Void> {
  private(set) var counter = 0
  let predicate: (RhExpr) -> Bool

  init(predicate: @escaping (RhExpr) -> Bool) {
    self.predicate = predicate
  }

  override func willVisitExpression(_ expression: RhExpr, _ context: Void) {
    if predicate(expression) {
      counter += 1
    }
  }
}
