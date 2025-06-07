// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MathExprTests {
  @Test
  func coverage() {
    let exprs: [MathExpr] = MathExprTests.allSamples()

    let rewriter = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.accept(rewriter, ())
      _ = expr.enumerateComponents()
    }
  }

  static func allSamples() -> Array<MathExpr> {
    [
      AccentExpr(MathAccent.ddot, [TextExpr("x")]),
      AttachExpr(
        nuc: [TextExpr("y")],
        lsub: [TextExpr("1")],
        lsup: [TextExpr("2")],
        sub: [TextExpr("3")],
        sup: [TextExpr("4")]),
      EquationExpr(.inline, [TextExpr("z")]),
      //
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], genfrac: .frac),
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], genfrac: .binom),
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], genfrac: .atop),
      //
      LeftRightExpr(DelimiterPair.BRACE, [TextExpr("M")]),
      MathAttributesExpr(.mathLimits(.limits), [TextExpr("world")]),
      MathStylesExpr(.mathfrak, [TextExpr("F")]),
      RadicalExpr([TextExpr("n")], [TextExpr("3")]),
      TextModeExpr([TextExpr("Hello")]),
    ]
  }
}
