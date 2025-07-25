import Foundation
import Testing

@testable import SwiftRohan

struct MathMiscNodesTests {

  static func allSamples() -> Array<Node> {
    [
      MathExpressionNode(MathExpression.colon),
      MathOperatorNode(MathOperator.min),
      NamedSymbolNode(NamedSymbol("rightarrow", "→")),
      MathStylesNode(MathStyles.mathfrak, [TextNode("F")]),
    ]
  }
}
