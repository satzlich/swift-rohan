// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MiscExprTests {
  @Test
  func coverage() {
    let exprs: Array<Expr> = MiscExprTests.allSamples()

    let rewriter = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.accept(rewriter, ())
    }
  }

  static func allSamples() -> Array<Expr> {
    [
      CounterExpr(.equation),
      LinebreakExpr(),
      TextExpr("Hello"),
      UnknownExpr(JSONValue.string("Hello")),
    ]
  }
}
