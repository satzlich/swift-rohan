// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct NodeLengthTests {
    private static func sampleTree() -> RootNode {
        RootNode([
            HeadingNode(
                level: 1,
                [TextNode("abc"),
                 EmphasisNode([TextNode("def😀")])]
            ),
            ParagraphNode([
                TextNode("hijk"),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode([TextNode("a+b")])
                ),
            ]),
        ])
    }

    @Test
    static func testLength() {
        let root = sampleTree()

        #expect(root.lengthTree().description ==
            """
            (14, [(7, [`3`, (4, [`4`])]), (7, [`4`, (3, [(3, [`3`])])])])
            """)

        #expect(root.nsLengthTree().description ==
            """
            (13, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(3, [`3`])])])])
            """)
    }

    @Test
    static func test_locate_offset() {
        let root = sampleTree()
        do {
            let (path, offset) = root.locate(10)
            #expect(path.description == "[1, 0]")
            #expect(offset == 3)
            #expect(root.offset(path) == 7)
        }

        do {
            let (path, offset) = root.locate(13)
            #expect(path.description == "[1, 1, nucleus, 0]")
            #expect(offset == 2)
            #expect(root.offset(path) == 11)
        }
    }
}
