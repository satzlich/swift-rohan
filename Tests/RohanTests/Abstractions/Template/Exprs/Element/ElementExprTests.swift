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
      HeadingExpr(.sectionAst),
      ItemListExpr(.enumerate),
      ParagraphExpr(),
      ParListExpr(),
      RootExpr(),
      TextStylesExpr(.textbf),
    ]
  }
}
