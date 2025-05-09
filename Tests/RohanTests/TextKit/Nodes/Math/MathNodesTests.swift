// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MathNodesTests {
  @Test
  func coverage() {
    let nodes: [MathNode] = MathNodesTests.allSamples()

    for node in nodes {
      _ = node.enumerateComponents()
      for index in MathIndex.allCases {
        _ = node.allowsComponent(index)
      }
      _ = node.layoutFragment
    }
  }

  static func allSamples() -> Array<MathNode> {
    [
      AccentNode(accent: Characters.dotAbove, nucleus: [TextNode("x")]),
      AttachNode(
        nuc: [TextNode("a")], lsub: [TextNode("1")], lsup: [TextNode("2")],
        sub: [TextNode("3")], sup: [TextNode("4")]),
      EquationNode(isBlock: false, nuc: [TextNode("f(n)")]),
      
    ]
  }
}
