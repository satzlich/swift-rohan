// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct MathNodesTests {
  @Test
  func coverage() {
    let nodes: [MathNode] = UnderOverNodeTests.allSamples() + MathNodesTests.allSamples()

    for node in nodes {
      _ = node.enumerateComponents()
      for index in MathIndex.allCases {
        _ = node.allowsComponent(index)
      }
      _ = node.layoutFragment

      #expect(node.layoutLength() == 1)
    }
  }

  static func allSamples() -> Array<MathNode> {
    [
      AccentNode(MathAccent.dot, nucleus: [TextNode("x")]),
      AttachNode(
        nuc: [TextNode("a")], lsub: [TextNode("1")], lsup: [TextNode("2")],
        sub: [TextNode("3")], sup: [TextNode("4")]),
      EquationNode(.inline, [TextNode("f(n)")]),
      //
      FractionNode(num: [TextNode("x")], denom: [TextNode("y")], genfrac: .frac),
      FractionNode(num: [TextNode("x")], denom: [TextNode("y")], genfrac: .binom),
      FractionNode(num: [TextNode("x")], denom: [TextNode("y")], genfrac: .atop),
      //
      LeftRightNode(DelimiterPair.BRACE, [TextNode("x")]),
      MathAttributesNode(.mathLimits(.limits), [TextNode("world")]),
      RadicalNode([TextNode("m")], [TextNode("n")]),
      TextModeNode([TextNode("max")]),
    ]
  }

  // MARK: - Subclasses

  @Test
  static func getProperties() {
    let styleSheet = StyleSheets.latinModern(12)

    // NOTE: isBlock = false
    // check property policy for equation, fraction
    do {
      let fraction = FractionNode(
        num: [TextNode("m+n")], denom: [TextNode("n")])
      let equation = EquationNode(.inline, [fraction])

      do {
        let properties = equation.getProperties(styleSheet)
        #expect(properties[MathProperty.font] == nil)
        #expect(properties[MathProperty.style] == .mathStyle(.text))
      }
      do {
        let properties = fraction.numerator.getProperties(styleSheet)
        #expect(properties[MathProperty.style] == .mathStyle(.script))
      }
      do {
        let properties = fraction.denominator.getProperties(styleSheet)
        #expect(properties[MathProperty.style] == .mathStyle(.script))
      }
    }

    // NOTE: isBlock = true
    // check property policy for equation, fraction
    do {
      let fraction = FractionNode(
        num: [TextNode("m+n")], denom: [TextNode("n")])
      let equation = EquationNode(.block, [fraction])

      do {
        let properties = equation.getProperties(styleSheet)
        #expect(properties[MathProperty.font] == nil)
        #expect(properties[MathProperty.style] == .mathStyle(.display))
      }
      do {
        let properties = fraction.numerator.getProperties(styleSheet)
        #expect(properties[MathProperty.style] == .mathStyle(.text))
      }
      do {
        let properties = fraction.denominator.getProperties(styleSheet)
        #expect(properties[MathProperty.style] == .mathStyle(.text))
      }
    }
  }
}
