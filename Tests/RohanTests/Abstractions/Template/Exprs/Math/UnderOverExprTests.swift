// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct UnderOverExprTests {
  @Test
  func coverage() {
    let exprs: Array<MathExpr> = UnderOverExprTests.allSamples()

    let visitor = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.enumerateComponents()
      _ = expr.accept(visitor, ())
    }
  }

  static func allSamples() -> Array<MathExpr> {
    [
      UnderOverExpr(MathSpreader.overbrace, [TextExpr("a")]),
      UnderOverExpr(MathSpreader.overline, [TextExpr("b")]),
      UnderOverExpr(MathSpreader.underbrace, [TextExpr("c")]),
      UnderOverExpr(MathSpreader.underline, [TextExpr("d")]),
    ]
  }
}
