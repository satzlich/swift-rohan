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
      OverspreaderNode(Chars.overBrace, [TextNode("a")]),
      UnderspreaderNode(Chars.underBrace, [TextNode("a")]),
    ]
  }
}
