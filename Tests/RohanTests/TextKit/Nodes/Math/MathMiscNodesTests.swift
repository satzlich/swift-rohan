// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MathMiscNodesTests {

  static func allSamples() -> Array<Node> {
    [
      MathExpressionNode(MathExpression.colon),
      MathOperatorNode(MathOperator.min),
      MathSymbolNode(MathSymbol("rightarrow", "→")),
      MathVariantNode(MathTextStyle.mathfrak, [TextNode("F")]),
    ]
  }
}
