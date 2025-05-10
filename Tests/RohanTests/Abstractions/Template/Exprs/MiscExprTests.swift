// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MiscExprTests {
  @Test
  func coverage() {
    let exprs: [Expr] = MiscExprTests.allSamples()

    let rewriter = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.accept(rewriter, ())
    }
  }

  static func allSamples() -> [Expr] {
    [
      LinebreakExpr(),
      TextExpr("Hello"),
      UnknownExpr(JSONValue.string("Hello")),
    ]
  }
}
