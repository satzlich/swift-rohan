// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct UnderOverNodeTests {
  static func allSamples() -> [MathNode] {
    [
      UnderOverNode(MathSpreader.overbrace, [TextNode("a")]),
      UnderOverNode(MathSpreader.overline, [TextNode("a")]),
      UnderOverNode(MathSpreader.underbrace, [TextNode("a")]),
      UnderOverNode(MathSpreader.underline, [TextNode("a")]),
    ]
  }
}
