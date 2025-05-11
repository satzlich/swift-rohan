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
      _ = expr.enumerateCompoennts()
    }
  }

  static func allSamples() -> Array<MathExpr> {
    [
      AccentExpr(Chars.dotAbove, [TextExpr("x")]),
      AttachExpr(
        nuc: [TextExpr("y")],
        lsub: [TextExpr("1")],
        lsup: [TextExpr("2")],
        sub: [TextExpr("3")],
        sup: [TextExpr("4")]),
      EquationExpr(isBlock: false, [TextExpr("z")]),
      //
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], subtype: .fraction),
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], subtype: .binomial),
      FractionExpr(num: [TextExpr("a")], denom: [TextExpr("b")], subtype: .atop),
      //
      LeftRightExpr(DelimiterPair.BRACE, [TextExpr("M")]),
      RadicalExpr([TextExpr("n")], [TextExpr("3")]),
      TextModeExpr([TextExpr("Hello")]),
    ]
  }
}
