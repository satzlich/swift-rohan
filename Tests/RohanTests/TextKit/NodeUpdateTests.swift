// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct NodeUpdateTests {
    @Test
    static func testInsertAndRemove_1() {
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

        // insert child
        let newParagraph = ParagraphNode([TextNode("X")])
        root.insertChild(newParagraph, at: 1)
        #expect(newParagraph.parent === root)

        // check
        #expect(root.textSynopsis() == "[[`0`, `1`], [`X`], [`2`, `3`], [`4`, `5`]]")
        #expect(root.lengthSynopsis() ==
            "(7, [(2, [`1`, `1`]), (1, [`1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])")

        // remove child
        root.removeChild(at: 2)
        #expect(root.textSynopsis() == "[[`0`, `1`], [`X`], [`4`, `5`]]")
        #expect(root.lengthSynopsis() == "(5, [(2, [`1`, `1`]), (1, [`1`]), (2, [`1`, `1`])])")
    }

    @Test
    static func testInsertAndRemove_2() {
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

        // insert grandchild
        let newText = TextNode("X")
        (root.getChild(1) as! ParagraphNode).insertChild(newText, at: 1)

        #expect(root.textSynopsis() == "[[`0`, `1`], [`2`, `X`, `3`], [`4`, `5`]]")
        #expect(root.lengthSynopsis() == "(7, [(2, [`1`, `1`]), (3, [`1`, `1`, `1`]), (2, [`1`, `1`])])")

        // remove grandchild
        (root.getChild(1) as! ParagraphNode).removeChild(at: 2)

        #expect(root.textSynopsis() == "[[`0`, `1`], [`2`, `X`], [`4`, `5`]]")
        #expect(root.lengthSynopsis() ==
            "(6, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])")
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
                EmphasisNode([
                    TextNode("3"),
                ]),
            ]),
            ParagraphNode([
                TextNode("4"),
                TextNode("5"),
            ]),
        ])

        let newParagraph = (root.getChild(1) as! ParagraphNode).deepCopy()
        #expect(newParagraph.parent == nil)
        #expect(newParagraph.textSynopsis() == "[`2`, [`3`]]")
        #expect(newParagraph.lengthSynopsis() == "(2, [`1`, (1, [`1`])])")

        (newParagraph.getChild(1) as! EmphasisNode).insertChild(TextNode("X"), at: 1)

        // check new paragraph
        #expect(newParagraph.textSynopsis() == "[`2`, [`3`, `X`]]")
        #expect(newParagraph.lengthSynopsis() == "(3, [`1`, (2, [`1`, `1`])])")

        // insert to new root
        root.insertChild(newParagraph, at: 3)
        #expect(root.textSynopsis() == "[[`0`, `1`], [`2`, [`3`]], [`4`, `5`], [`2`, [`3`, `X`]]]")
        #expect(root.lengthSynopsis() ==
            """
            (9, [\
            (2, [`1`, `1`]), \
            (2, [`1`, (1, [`1`])]), \
            (2, [`1`, `1`]), \
            (3, [`1`, (2, [`1`, `1`])])\
            ])
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

        #expect(root.lengthSynopsis() ==
            "(14, [(7, [`3`, (4, [`4`])]), (7, [`4`, (3, [(3, [`3`])])])])")

        #expect(root.nsLengthSynopsis() ==
            "(14, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(3, [`3`])])])])")

        ((root.getChild(1) as! ParagraphNode)
            .getChild(1) as! EquationNode)
            .nucleus
            .insertChild(TextNode("X"), at: 1)

        #expect(root.lengthSynopsis() ==
            "(15, [(7, [`3`, (4, [`4`])]), (8, [`4`, (4, [(4, [`3`, `1`])])])])")
        #expect(root.nsLengthSynopsis() ==
            "(14, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(4, [`3`, `1`])])])])")
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
            #expect("\(path)" == "[0, 1, 0]")
            #expect(offset == 4)
            #expect(root.offset(path) == 7 - 4)
        }

        do {
            let (path, offset) = root.locate(7, .downstream)
            #expect("\(path)" == "[1, 0]")
            #expect(offset == 0)
            #expect(root.offset(path) == 7)
        }

        do {
            let (path, offset) = root.locate(10)
            #expect("\(path)" == "[1, 0]")
            #expect(offset == 3)
            #expect(root.offset(path) == 10 - 3)
        }

        do {
            let (path, offset) = root.locate(13)
            #expect("\(path)" == "[1, 1, nucleus, 0]")
            #expect(offset == 2)
            #expect(root.offset(path) == 13 - 2)
        }
    }
}
