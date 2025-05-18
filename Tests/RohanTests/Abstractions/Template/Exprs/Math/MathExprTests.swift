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
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], subtype: .frac),
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], subtype: .binom),
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], subtype: .atop),
      //
      LeftRightExpr(DelimiterPair.BRACE, [TextExpr("M")]),
      MathKindExpr(.mathpunct, [TextExpr(":")]),
      RadicalExpr([TextExpr("n")], [TextExpr("3")]),
      TextModeExpr([TextExpr("Hello")]),
    ]
  }
}
