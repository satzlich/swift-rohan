// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct UnderOverNodeTests {
  static func allSamples() -> [MathNode] {
    [
      OverlineNode([TextNode("a")]),
      UnderlineNode([TextNode("a")]),
      OverspreaderNode(MathSpreader.overbrace, [TextNode("a")]),
      UnderspreaderNode(MathSpreader.underbrace, [TextNode("a")]),
    ]
  }
}
