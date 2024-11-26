// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class NodeTests: XCTestCase {
    func testNodes() {
        _ = RootNode([
            HeadingNode(
                level: 1,
                [
                    TextNode("Euclidean Geometry"),
                ]
            ),
            ParagraphNode([
                TextNode("Pythogorean equation:"),
                // a^2 + b^2 = c^2
                EquationNode(
                    isBlock: true,
                    [
                        TextNode("a"),
                        ScriptsNode(superscript: [TextNode("2")]),
                        TextNode("+b"),
                        ScriptsNode(superscript: [TextNode("2")]),
                        TextNode("=c"),
                        ScriptsNode(superscript: [TextNode("2")]),
                    ]
                ),
                TextNode("Newton's second law:"),
                // a = F/m
                EquationNode(
                    isBlock: true,
                    [
                        TextNode("a="),
                        FractionNode(numerator: [TextNode("F")],
                                     denominator: [TextNode("m")]),
                    ]
                ),
                TextNode("Matrix representation of a complex:"),
                // a+ib <-> [[a, b], [-b, a]]
                EquationNode(
                    isBlock: true,
                    [
                        TextNode("a+ib"),
                        ApplyNode("leftrightarrow"),
                        MatrixNode(
                            [
                                [[TextNode("a")], [TextNode("b")]],
                                [[TextNode("-b")], [TextNode("a")]],
                            ]
                        ),
                    ]
                ),
            ]),
        ])
    }
}
