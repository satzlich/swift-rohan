// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ElementExprTests {
  @Test
  func coverage() {
    let elements: Array<ElementExpr> = ElementExprTests.allSamples()

    let visitor = ExpressionRewriter<Void>()
    for element in elements {
      _ = element.with(children: [TextExpr("test")])
      _ = element.accept(visitor, ())
    }
  }

  static func allSamples() -> Array<ElementExpr> {
    [
      ContentExpr(),
      TextStylesExpr(.emph),
      HeadingExpr(level: 1),
      ItemListExpr(.enumerate),
      ParagraphExpr(),
      RootExpr(),
      TextStylesExpr(.textbf),
    ]
  }

  @Test
  func headingExpr() {
    for i in 1...5 {
      let expr = HeadingExpr(level: i)
      _ = expr.subtype
    }
  }
}
