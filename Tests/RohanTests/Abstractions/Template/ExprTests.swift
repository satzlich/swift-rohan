// Copyright 2024 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ExprTests {
  private final class CountingExpressionWalker: ExpressionWalker<Void> {
    private(set) var types: Set<ExprType> = []
    private(set) var count: Int = 0

    override func willVisitExpression(_ expression: Expr, _ context: Void) {
      count += 1
      types.insert(expression.type)
    }
  }

  @Test
  static func test_VisitorImplementation() {
    let sample = ContentExpr(sampleElements() + [sampleMath()])
    do {
      let walker = CountingExpressionWalker()
      walker.traverseExpression(sample, ())
      #expect(walker.count == 30)
      #expect(walker.types.count == 9)
    }
  }

  @Test
  static func test_Elements() {
    let elements: [ElementExpr] = sampleElements()
    let content = ContentExpr(elements)

    #expect(
      content.prettyPrint() == """
        content
        ├ heading level: 1
        │ └ text "Heading 1"
        └ paragraph
          ├ text "Paragraph 1"
          └ emphasis
            └ text "Emphasized text"
        """)
  }

  private static func sampleElements() -> [ElementExpr] {
    [
      HeadingExpr(level: 1, [TextExpr("Heading 1")]),
      ParagraphExpr([
        TextExpr("Paragraph 1"),
        EmphasisExpr([TextExpr("Emphasized text")]),
      ]),
    ]
  }

  private static func sampleMath() -> Expr {
    EquationExpr(
      isBlock: true,
      [
        AttachExpr(
          nuc: [TextExpr("Fe")], sub: [TextExpr("3+")], sup: [TextExpr("2")]),
        FractionExpr(
          num: [TextExpr("m")], denom: [TextExpr("n+2")],
          isBinomial: false),
        MatrixExpr(
          [
            MatrixExpr.Row([[TextExpr("a")], [TextExpr("b")]]),
            MatrixExpr.Row([[TextExpr("c")], [TextExpr("d")]]),
          ], DelimiterPair.BRACE),
      ])
  }

  @Test
  static func test_Math() {
    let math = sampleMath()
    #expect(
      math.prettyPrint() == """
        equation isBlock: true
        └ nuc
          ├ attach
          │ ├ nuc
          │ │ └ text "Fe"
          │ ├ sub
          │ │ └ text "3+"
          │ └ sup
          │   └ text "2"
          ├ fraction isBinomial: false
          │ ├ num
          │ │ └ text "m"
          │ └ denom
          │   └ text "n+2"
          └ matrix 2x2
            ├ row 0
            │ ├ content
            │ │ └ text "a"
            │ └ content
            │   └ text "b"
            └ row 1
              ├ content
              │ └ text "c"
              └ content
                └ text "d"
        """)
  }
}
