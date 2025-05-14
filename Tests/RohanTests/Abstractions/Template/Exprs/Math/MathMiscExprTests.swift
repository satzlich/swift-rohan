// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MathMiscExprTests {
  @Test
  func coverage() {
    let exprs: [Expr] = MathMiscExprTests.allSamples()

    let rewriter = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.accept(rewriter, ())
    }
  }

  static func allSamples() -> [Expr] {
    [
      MathOperatorExpr(MathOperator.min),
      MathSymbolExpr(MathSymbol("rightarrow", "→")),
      MathVariantExpr(.mathfrak, [TextExpr("F")]),
    ]
  }
}
