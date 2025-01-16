// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct NodeCOWTests {
    @Test
    static func testCOW() {
        let root = RootNode([
            ParagraphNode([
                TextNode("0"),
                TextNode("1"),
                TextNode("2"),
                TextNode("3"),
            ]),
            ParagraphNode([
                TextNode("4"),
                TextNode("5"),
                TextNode("6"),
                TextNode("7"),
            ]),
            ParagraphNode([
                TextNode("8"),
                TextNode("9"),
                TextNode("10"),
                TextNode("11"),
            ]),
        ])
    }
}
