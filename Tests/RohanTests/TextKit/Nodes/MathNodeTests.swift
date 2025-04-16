// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

struct MathNodeTests {
  @Test
  static func test_getProperties() {
    let styleSheet = StyleSheet.latinModern(12)

    // NOTE: isBlock = false
    // check property policy for equation, fraction
    do {
      let fraction = FractionNode(
        numerator: [TextNode("m+n")], denominator: [TextNode("n")])
      let equation = EquationNode(isBlock: false, nucleus: [fraction])

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
        numerator: [TextNode("m+n")], denominator: [TextNode("n")])
      let equation = EquationNode(isBlock: true, nucleus: [fraction])

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

  /// intrinsic length, extrinsic length, and layout length
  @Test
  static func testLength() {
    let equation = EquationNode(
      isBlock: false,
      nucleus: [
        TextNode("x+"),
        FractionNode(
          numerator: [TextNode("m+n")], denominator: [TextNode("2n")], isBinomial: true),
      ]
    )
    #expect(equation.layoutLength() == 1)

    let fraction = FractionNode(
      numerator: [TextNode("m+n")], denominator: [TextNode("2n")])
    #expect(fraction.layoutLength() == 1)
  }
}
