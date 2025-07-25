import Foundation
import Testing

@testable import SwiftRohan

struct MathMiscExprTests {
  @Test
  func coverage() {
    let exprs: Array<Expr> = MathMiscExprTests.allSamples()

    let rewriter = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.accept(rewriter, ())
    }
  }

  static func allSamples() -> Array<Expr> {
    [
      MathExpressionExpr(MathExpression.colon),
      MathOperatorExpr(MathOperator.min),
      NamedSymbolExpr(NamedSymbol("rightarrow", "→")),
    ]
  }
}
