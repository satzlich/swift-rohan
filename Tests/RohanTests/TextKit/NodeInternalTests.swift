// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct NodeInternalTests {
    @Test
    static func testSample() {
        let root = RootNode([
            ParagraphNode([
                TextNode("0"), TextNode("1"),
            ]),
            ParagraphNode([
                TextNode("2"), TextNode("3"),
            ]),
            ParagraphNode([
                TextNode("4"), TextNode("5"),
            ]),
        ])
        #expect(root.synopsis() == "0|1|2|3|4|5")
        #expect(root.lengthTree().description ==
            """
            (6, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
            """)
    }

    @Test
    static func testInsertAndRemove() {
        let root = RootNode([
            ParagraphNode([
                TextNode("0"), TextNode("1"),
            ]),
            ParagraphNode([
                TextNode("2"), TextNode("3"),
            ]),
            ParagraphNode([
                TextNode("4"), TextNode("5"),
            ]),
        ])

        do {
            // copy new root
            let newRoot = root.copy()
            #expect(newRoot.getChild(0, ensureUnique: false).parent === root)
            #expect(newRoot.getChild(0, ensureUnique: true).parent === newRoot)
            #expect(newRoot.getChild(0, ensureUnique: false).parent === newRoot)

            // insert child
            let newParagraph = ParagraphNode([TextNode("X")])
            newRoot.insertChild(newParagraph, at: 1)
            #expect(newParagraph.parent === newRoot)

            // check
            #expect(newRoot.synopsis() == "0|1|X|2|3|4|5")
            #expect(newRoot.lengthTree().description ==
                """
                (7, [(2, [`1`, `1`]), (1, [`1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
                """)

            // remove child
            newRoot.removeChild(at: 2)
            #expect(newRoot.synopsis() == "0|1|X|4|5")
            #expect(newRoot.lengthTree().description ==
                """
                (5, [(2, [`1`, `1`]), (1, [`1`]), (2, [`1`, `1`])])
                """)
        }

        do {
            // copy root
            let newRoot = root.copy()

            // insert grandchild
            let newText = TextNode("X")
            (newRoot.getChild(1) as! ParagraphNode).insertChild(newText, at: 1)

            #expect(newRoot.synopsis() == "0|1|2|X|3|4|5")
            #expect(newRoot.lengthTree().description ==
                """
                (7, [(2, [`1`, `1`]), (3, [`1`, `1`, `1`]), (2, [`1`, `1`])])
                """)

            // remove grandchild
            (newRoot.getChild(1) as! ParagraphNode).removeChild(at: 2)

            #expect(newRoot.synopsis() == "0|1|2|X|4|5")
            #expect(newRoot.lengthTree().description ==
                """
                (6, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
                """)
        }

        // check old root
        #expect(root.synopsis() == "0|1|2|3|4|5")
        #expect(root.lengthTree().description ==
            """
            (6, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
            """)
    }

    @Test
    static func testCopyAndInsert() {
        let root = RootNode([
            ParagraphNode([
                TextNode("0"),
                TextNode("1"),
            ]),
            ParagraphNode([
                TextNode("2"),
                TextNode("3"),
            ]),
            ParagraphNode([
                TextNode("4"),
                TextNode("5"),
            ]),
        ])

        // copy to segment
        var segment: [Node] = []
        guard let paragraph = root.getChild(1) as? ParagraphNode else {
            #expect(Bool(false))
            return
        }
        for i in (1 ..< paragraph.childCount()) {
            segment.append(paragraph.getChild(i, ensureUnique: false).copy())
        }
        segment.forEach {
            #expect($0.parent == nil)
        }

        // create new paragraph
        let newParagraph = ParagraphNode(segment)
        newParagraph.insertChild(TextNode("X"), at: 1)

        // check new paragraph
        #expect(newParagraph.synopsis() == "3|X")
        #expect(newParagraph.lengthTree().description == "(2, [`1`, `1`])")

        // insert to new root
        let newRoot = root.copy()
        newRoot.insertChild(newParagraph, at: 3)
        #expect(newRoot.synopsis() == "0|1|2|3|4|5|3|X")
        #expect(newRoot.lengthTree().description ==
            """
            (8, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
            """)

        // check old root
        #expect(root.getChild(0).parent === root)
        #expect(root.synopsis() == "0|1|2|3|4|5")
        #expect(root.lengthTree().description ==
            """
            (6, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
            """)
    }

    @Test
    static func testLength() {
        let root = RootNode([
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

        #expect(root.lengthTree().description ==
            """
            (14, [(7, [`3`, (4, [`4`])]), (7, [`4`, (3, [(3, [`3`])])])])
            """)

        #expect(root.nsLengthTree().description ==
            """
            (13, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(3, [`3`])])])])
            """)

        ((root.getChild(1, ensureUnique: false) as! ParagraphNode)
            .getChild(1, ensureUnique: false) as! EquationNode)
            .nucleus
            .insertChild(TextNode("X"), at: 1)

        #expect(root.lengthTree().description ==
            """
            (15, [(7, [`3`, (4, [`4`])]), (8, [`4`, (4, [(4, [`3`, `1`])])])])
            """)
        #expect(root.nsLengthTree().description ==
            """
            (13, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(4, [`3`, `1`])])])])
            """)
    }

    @Test
    static func test_locate_offset() {
        let root = RootNode([
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

        do {
            let (path, offset) = root.locate(7, .upstream)
            #expect(path.description == "[0, 1, 0]")
            #expect(offset == 4)
            #expect(root.offset(path) == 7 - 4)
        }

        do {
            let (path, offset) = root.locate(7, .downstream)
            #expect(path.description == "[1, 0]")
            #expect(offset == 0)
            #expect(root.offset(path) == 7)
        }

        do {
            let (path, offset) = root.locate(10)
            #expect(path.description == "[1, 0]")
            #expect(offset == 3)
            #expect(root.offset(path) == 10 - 3)
        }

        do {
            let (path, offset) = root.locate(13)
            #expect(path.description == "[1, 1, nucleus, 0]")
            #expect(offset == 2)
            #expect(root.offset(path) == 13 - 2)
        }
    }
}
