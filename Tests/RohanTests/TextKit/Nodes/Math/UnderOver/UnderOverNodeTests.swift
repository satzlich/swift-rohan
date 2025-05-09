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
      OverspreaderNode(Characters.overBrace, [TextNode("a")]),
      UnderspreaderNode(Characters.underBrace, [TextNode("a")]),
    ]
  }
}
