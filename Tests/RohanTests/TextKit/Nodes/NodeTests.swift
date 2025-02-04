// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct NodeTests {
    // MARK: - Children

    /** insert and remove child */
    @Test
    static func test_insertChild_removeChild_1() {
        let root = RootNode([
            ParagraphNode([
                TextNode("01"),
            ]),
            ParagraphNode([
                TextNode("23"),
            ]),
            ParagraphNode([
                TextNode("45"),
            ]),
        ])

        // insert child
        let newParagraph = ParagraphNode([TextNode("X")])
        root.insertChild(newParagraph, at: 1)
        #expect(newParagraph.parent === root)

        // check
        #expect(root.textSynopsis() == "[[`01`], [`X`], [`23`], [`45`]]")
        #expect(root.lengthSynopsis() ==
            "(11, [(3, [`2`]), (2, [`1`]), (3, [`2`]), (3, [`2`])])")

        // remove child
        root.removeChild(at: 2)
        #expect(root.textSynopsis() == "[[`01`], [`X`], [`45`]]")
        #expect(root.lengthSynopsis() ==
            "(8, [(3, [`2`]), (2, [`1`]), (3, [`2`])])")
    }

    /** insert and remove grandchild */
    @Test
    static func test_insertChild_removeChild_2() {
        let root = RootNode([
            ParagraphNode([
                TextNode("01"),
            ]),
            ParagraphNode([
                TextNode("23"),
            ]),
            ParagraphNode([
                TextNode("45"),
            ]),
        ])

        // insert grandchild
        let newText = TextNode("X")
        (root.getChild(1) as! ParagraphNode).insertChild(newText, at: 1)

        #expect(root.textSynopsis() == "[[`01`], [`23`, `X`], [`45`]]")
        #expect(root.lengthSynopsis() ==
            "(10, [(3, [`2`]), (4, [`2`, `1`]), (3, [`2`])])")

        // remove grandchild
        (root.getChild(1) as! ParagraphNode).removeChild(at: 0)

        #expect(root.textSynopsis() == "[[`01`], [`X`], [`45`]]")
        #expect(root.lengthSynopsis() ==
            "(8, [(3, [`2`]), (2, [`1`]), (3, [`2`])])")
    }

    @Test
    static func test_deepCopy_insertChild() {
        let root = RootNode([
            ParagraphNode([
                TextNode("01"),
            ]),
            ParagraphNode([
                TextNode("2"),
                EmphasisNode([
                    TextNode("3"),
                ]),
            ]),
            ParagraphNode([
                TextNode("45"),
            ]),
        ])

        let newParagraph = (root.getChild(1) as! ParagraphNode).deepCopy()
        #expect(newParagraph.parent == nil)
        #expect(newParagraph.textSynopsis() == "[`2`, [`3`]]")
        #expect(newParagraph.lengthSynopsis() == "(5, [`1`, (3, [`1`])])")

        (newParagraph.getChild(1) as! EmphasisNode).insertChild(TextNode("X"), at: 1)

        // check new paragraph
        #expect(newParagraph.textSynopsis() == "[`2`, [`3`, `X`]]")
        #expect(newParagraph.lengthSynopsis() == "(6, [`1`, (4, [`1`, `1`])])")

        // insert to new root
        root.insertChild(newParagraph, at: 3)
        #expect(root.textSynopsis() ==
            "[[`01`], [`2`, [`3`]], [`45`], [`2`, [`3`, `X`]]]")
        #expect(root.lengthSynopsis() ==
            """
            (17, [\
            (3, [`2`]), \
            (5, [`1`, (3, [`1`])]), \
            (3, [`2`]), \
            (6, [`1`, (4, [`1`, `1`])])\
            ])
            """)
    }

    @Test
    static func test_compactSubrange() {
        let paragraph = ParagraphNode([
            TextNode("0"),
            TextNode("1"),
            TextNode("2"),
            TextNode("3"),
        ])
        #expect(paragraph.textSynopsis() == "[`0`, `1`, `2`, `3`]")
        #expect(paragraph.lengthSynopsis() == "(5, [`1`, `1`, `1`, `1`])")

        do {
            let compacted = paragraph.compactSubrange(1 ..< 3, inContentStorage: false)
            #expect(compacted == true)
            #expect(paragraph.textSynopsis() == "[`0`, `12`, `3`]")
            #expect(paragraph.lengthSynopsis() == "(5, [`1`, `2`, `1`])")
        }

        do {
            let compacted = paragraph.compactSubrange(0 ..< paragraph.childCount(),
                                                      inContentStorage: false)
            #expect(compacted == true)
            #expect(paragraph.textSynopsis() == "[`0123`]")
            #expect(paragraph.lengthSynopsis() == "(5, [`4`])")
        }

        do {
            let compacted = paragraph.compactSubrange(0 ..< paragraph.childCount(),
                                                      inContentStorage: false)
            #expect(compacted == false)
            #expect(paragraph.textSynopsis() == "[`0123`]")
            #expect(paragraph.lengthSynopsis() == "(5, [`4`])")
        }
    }

    // MARK: - Length & Location

    @Test
    static func test_length_layoutLength() {
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
                    [TextNode("a+b")]
                ),
            ]),
        ])

        #expect(root.lengthSynopsis() ==
            "(21, [(11, [`3`, (6, [`4`])]), (10, [`4`, (5, [(3, [`3`])])])])")
        #expect(root.layoutLengthSynopsis() ==
            "(14, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(3, [`3`])])])])")

        ((root.getChild(1) as! ParagraphNode)
            .getChild(1) as! EquationNode)
            .nucleus
            .insertChild(TextNode("X"), at: 1)

        #expect(root.lengthSynopsis() ==
            "(22, [(11, [`3`, (6, [`4`])]), (11, [`4`, (6, [(4, [`3`, `1`])])])])")
        #expect(root.layoutLengthSynopsis() ==
            "(14, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(4, [`3`, `1`])])])])")
    }

    @Test
    static func test_locate() {
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
                    [TextNode("a+b")]
                ),
            ]),
        ])

        #expect(root.length == 21)

        do {
            let location = root.locate(0)
            #expect("\(location.path)" == "[]")
            #expect(location.offset == 0)
            #expect(root.offset(for: location) == 0)
        }
        do {
            let location = root.locate(4)
            #expect("\(location.path)" == "[0→]")
            #expect(location.offset == 4)
            #expect(root.offset(for: location) == 4)
        }
        do {
            let location = root.locate(5)
            #expect("\(location.path)" == "[0→, 4→]")
            #expect(location.offset == 1)
            #expect(root.offset(for: location) == 5)
        }
        do {
            let location = root.locate(11)
            #expect("\(location.path)" == "[11]")
            #expect(location.offset == 0)
            #expect(root.offset(for: location) == 11)
        }
        do {
            let location = root.locate(15)
            #expect("\(location.path)" == "[11]")
            #expect(location.offset == 4)
            #expect(root.offset(for: location) == 15)
        }
        do {
            let location = root.locate(16)
            #expect("\(location.path)" == "[11, 4→, nucleus]")
            #expect(location.offset == 0)
            #expect(root.offset(for: location) == 16)
        }
        do {
            let location = root.locate(20)
            #expect("\(location.path)" == "[11]")
            #expect(location.offset == 9)
            #expect(root.offset(for: location) == 20)
        }
        do {
            let location = root.locate(21)
            #expect("\(location.path)" == "[]")
            #expect(location.offset == 21)
            #expect(root.offset(for: location) == 21)
        }
    }
}
