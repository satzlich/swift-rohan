// Copyright 2024-2025 Lie Yan

@testable import RohanMinimal
import Foundation
import Testing

struct NodeTests {
    @Test
    static func testNode() {
        let root = RootNode([
            HeadingNode(level: 1, [
                TextNode("Alpha"),
                EmphasisNode([
                    TextNode("Beta Charlie 😀"),
                ]),
            ]),
            ParagraphNode([
                TextNode("The quick brown fox "),
                EmphasisNode([
                    TextNode("jumps over the "),
                    EmphasisNode([
                        TextNode("lazy "),
                    ]),
                    TextNode("dog."),
                ]),
            ]),
            ParagraphNode([
                TextNode("The equation is "),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode([TextNode("a+b=c")])
                ),
                TextNode("."),
            ]),
        ])
    }
}
