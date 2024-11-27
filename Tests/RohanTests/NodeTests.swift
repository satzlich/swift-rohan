// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class NodeTests: XCTestCase {
    func testNodes() {
        _ =
            RootNode(
                HeadingNode(
                    level: 1,
                    [
                        TextNode("Demo of nodes"),
                    ]
                )!,
                ParagraphNode(
                    TextNode("Pythogorean equation:"),
                    // a^2 + b^2 = c^2
                    EquationNode(
                        isBlock: false,
                        [
                            TextNode("a"),
                            ScriptsNode(superscript: TextNode("2")),
                            TextNode("+b"),
                            ScriptsNode(superscript: TextNode("2")),
                            TextNode("=c"),
                            ScriptsNode(superscript: TextNode("2")),
                        ]
                    ),
                    TextNode(". Newton's second law:"),
                    // a = F/m
                    EquationNode(
                        isBlock: false,
                        [
                            TextNode("a="),
                            FractionNode(numerator: TextNode("F"),
                                         denominator: TextNode("m")),
                        ]
                    ),
                    TextNode(". Matrix representation of a "),
                    EmphasisNode(TextNode("complex ")),
                    TextNode("number:"),
                    // a+ib <-> [[a, b], [-b, a]]
                    EquationNode(
                        isBlock: true,
                        [
                            TextNode("a+ib"),
                            ApplyNode("leftrightarrow"),
                            MatrixNode(
                                [[TextNode("a")], [TextNode("b")]],
                                [[TextNode("-b")], [TextNode("a")]]
                            ),
                        ]
                    ),
                    TextNode("Fibonacci number:"),
                    EquationNode(
                        isBlock: true,
                        [
                            ApplyNode("fib", arguments: [TextNode("n+2")]),
                            TextNode("="),
                            ApplyNode("fib", arguments: [TextNode("n+1")]),
                            TextNode("+"),
                            ApplyNode("fib", arguments: [TextNode("n")]),
                        ]
                    )
                )
            )
    }
}
