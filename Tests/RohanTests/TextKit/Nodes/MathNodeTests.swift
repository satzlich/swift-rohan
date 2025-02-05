// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct MathNodeTests {
    @Test
    static func test_getChild_getOffset() {
        // equation
        let equation = EquationNode(isBlock: false,
                                    [TextNode("a+b")])
        do {
            let nucleus = equation.getChild(.mathIndex(.nucleus)) as! ContentNode
            let text = nucleus.getChild(.arrayIndex(0)) as! TextNode
            #expect(text.bigString == "a+b")
        }
        #expect(equation.getOffset(before: .mathIndex(.nucleus)) == 1)

        // fraction
        let fraction = FractionNode([TextNode("m+n")],
                                    [TextNode("n")])
        do {
            let numerator = fraction.getChild(.mathIndex(.numerator)) as! ContentNode
            let numText = numerator.getChild(.arrayIndex(0)) as! TextNode
            #expect(numText.bigString == "m+n")
            let denominator = fraction.getChild(.mathIndex(.denominator)) as! ContentNode
            let denomText = denominator.getChild(.arrayIndex(0)) as! TextNode
            #expect(denomText.bigString == "n")
        }
        #expect(fraction.getOffset(before: .mathIndex(.numerator)) == 1)
        #expect(fraction.getOffset(before: .mathIndex(.denominator)) == 5)
    }

    @Test
    static func test_getProperties() {
        let styleSheet = StyleSheet.defaultValue(12)

        // NOTE: isBlock = false
        // check property policy for equation, fraction
        do {
            let fraction = FractionNode([TextNode("m+n")], [TextNode("n")])
            let equation = EquationNode(isBlock: false, [fraction])

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
            let fraction = FractionNode([TextNode("m+n")], [TextNode("n")])
            let equation = EquationNode(isBlock: true, [fraction])

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

    /** intrinsic length, extrinsic length, and layout length */
    @Test
    static func testLength() {
        let equation = EquationNode(
            isBlock: false,
            [
                TextNode("x+"),
                FractionNode([TextNode("m+n")], [TextNode("2n")]),
            ]
        )
        #expect(equation.intrinsicLength == 3)
        #expect(equation.extrinsicLength == 1)
        #expect(equation.layoutLength == 1)

        let fraction = FractionNode([TextNode("m+n")], [TextNode("2n")])
        #expect(fraction.intrinsicLength == 6)
        #expect(fraction.extrinsicLength == 1)
        #expect(fraction.layoutLength == 1)
    }
}
