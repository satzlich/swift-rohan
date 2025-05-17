// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ExprsTests {
  static var uncoveredExprTypes: Set<ExprType> = [.argument]

  @Test
  func coverage() {
    let exprs: [Expr] = ExprsTests.allSamples()

    let visitor1 = NaiveExprVisitor()
    let visitor2 = SimpleExprVisitor<Void>()
    let visitor3 = ExpressionWalker<Void>()
    let visitor4 = ExpressionRewriter<Void>()

    for expr in exprs {
      _ = expr.prettyPrint()
      expr.accept(visitor1, ())
      expr.accept(visitor2, ())
      expr.accept(visitor3, ())
      _ = expr.accept(visitor4, ())

      if [.apply, .variable].contains(expr.type) == false {
        _ = NodeUtils.convertExprs([expr])
      }
    }
  }

  @Test
  func countTypes() {
    let exprs: [Expr] = ExprsTests.allSamples()
    let walker = CountingExpressionWalker()
    for expr in exprs {
      expr.accept(walker, ())
    }
    let uncoveredTypes: Set<ExprType> = Set(ExprType.allCases).subtracting(walker.types)
    #expect(uncoveredTypes == ExprsTests.uncoveredExprTypes)
  }

  static func allSamples() -> [Expr] {
    var expressions: [Expr] = []
    expressions.append(contentsOf: ElementExprTests.allSamples())
    expressions.append(contentsOf: GridExprTests.allSamples())
    expressions.append(contentsOf: UnderOverExprTests.allSamples())
    expressions.append(contentsOf: MathExprTests.allSamples())
    expressions.append(contentsOf: MathMiscExprTests.allSamples())
    expressions.append(contentsOf: TemplateExprTests.allSamples())
    expressions.append(contentsOf: MiscExprTests.allSamples())
    return expressions
  }

  private final class NaiveExprVisitor: ExprVisitor<Void, Void> {
    override func visitExpr(_ expression: Expr, _ context: Void) -> Void {
      // no-op
    }
  }

  private final class CountingExpressionWalker: ExpressionWalker<Void> {
    private(set) var types: Set<ExprType> = []
    private(set) var count: Int = 0

    override func willVisitExpression(_ expression: Expr, _ context: Void) {
      count += 1
      types.insert(expression.type)
    }
  }
}
