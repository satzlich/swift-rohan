// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MathMiscNodesTests {

  static func allSamples() -> Array<Node> {
    [
      MathOperatorNode([TextNode("min")], true),
      MathSymbolNode(MathSymbol("rightarrow", "→")),
      MathVariantNode(.frak, [TextNode("F")]),
    ]
  }
}
