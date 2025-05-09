// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct UnderOverExprTests {
  @Test
  func coverage() {
    let exprs: [MathExpr] = UnderOverExprTests.allSamples()

    let visitor = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.enumerateCompoennts()
      _ = expr.accept(visitor, ())
    }
  }

  static func allSamples() -> Array<MathExpr> {
    [
      OverlineExpr([TextExpr("a")]),
      OverspreaderExpr(Characters.overBrace, [TextExpr("b")]),
      UnderlineExpr([TextExpr("c")]),
      UnderspreaderExpr(Characters.underShell, [TextExpr("d")]),
    ]
  }
}
