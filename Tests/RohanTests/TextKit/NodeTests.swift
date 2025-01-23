// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct NodeTests {
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
        #expect(root.paddedLengthSynopsis() ==
            "(21, [(11, [`3`, (6, [`4`])]), (10, [`4`, (5, [(3, [`3`])])])])")

        ((root.getChild(1) as! ParagraphNode)
            .getChild(1) as! EquationNode)
            .nucleus
            .insertChild(TextNode("X"), at: 1)

        #expect(root.lengthSynopsis() ==
            "(15, [(7, [`3`, (4, [`4`])]), (8, [`4`, (4, [(4, [`3`, `1`])])])])")
        #expect(root.nsLengthSynopsis() ==
            "(14, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(4, [`3`, `1`])])])])")
        #expect(root.paddedLengthSynopsis() ==
            "(22, [(11, [`3`, (6, [`4`])]), (11, [`4`, (6, [(4, [`3`, `1`])])])])")
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
            let (path, offset) = root.locate(0, .upstream)
            #expect("\(path)" == "[0, 0]")
            #expect(offset == 0)
            #expect(root.offset(path) == 0)
        }

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

    @Test
    static func testPadded_locate() {
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
            let (path, offset) = root.locate(forPadded: 0)
            #expect("\(path)" == "[0]")
            #expect(offset == nil)
            #expect(root.paddedOffset(for: path) == 0)
        }
        do {
            let (path, offset) = root.locate(forPadded: 4)
            #expect("\(path)" == "[0, 0]")
            #expect(offset == 3)
            #expect(root.paddedOffset(for: path + [.arrayIndex(offset!)]) == 4)
        }
        do {
            let (path, offset) = root.locate(forPadded: 5)
            #expect("\(path)" == "[0, 1, 0]")
            #expect(offset == 0)
            #expect(root.paddedOffset(for: path + [.arrayIndex(offset!)]) == 5)
        }
        do {
            let (path, offset) = root.locate(forPadded: 11)
            #expect("\(path)" == "[1, 0]")
            #expect(offset == 0)
            #expect(root.paddedOffset(for: path + [.arrayIndex(offset!)]) == 11)
        }
        do {
            let (path, offset) = root.locate(forPadded: 15)
            #expect("\(path)" == "[1, 0]")
            #expect(offset == 4)
            #expect(root.paddedOffset(for: path + [.arrayIndex(offset!)]) == 15)
        }
        do {
            let (path, offset) = root.locate(forPadded: 16)
            #expect("\(path)" == "[1, 1, nucleus, 0]")
            #expect(offset == 0)
            #expect(root.paddedOffset(for: path + [.arrayIndex(offset!)]) == 16)
        }
        do {
            let (path, offset) = root.locate(forPadded: 20)
            #expect("\(path)" == "[1, 2]")
            #expect(offset == nil)
            #expect(root.paddedOffset(for: path) == 20)
        }
        do {
            let (path, offset) = root.locate(forPadded: 21)
            #expect("\(path)" == "[2]")
            #expect(offset == nil)
            #expect(root.paddedOffset(for: path) == 21)
        }
    }

    @Test
    static func test_getProperties() {
        let content = ContentNode([
            HeadingNode(
                level: 1,
                [
                    TextNode("ab"),
                    EmphasisNode([TextNode("cd😀")]),
                ]
            ),
            ParagraphNode([
                TextNode("ef"),
                EmphasisNode([TextNode("gh")]),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode([TextNode("a+b")])
                ),
            ]),
        ])
        let styleSheet = StyleSheetTests.sampleStyleSheet()

        do {
            let heading = (content.getChild(0) as! HeadingNode)
            let emphasis = heading.getChild(1) as! EmphasisNode

            let headingProperties = heading.getProperties(with: styleSheet)
            let emphasisProperties = emphasis.getProperties(with: styleSheet)

            #expect(headingProperties[TextProperty.style] == .fontStyle(.italic))
            #expect(emphasisProperties[TextProperty.style] == .fontStyle(.normal))
        }

        do {
            let paragraph = (content.getChild(1) as! ParagraphNode)
            let emphasis = paragraph.getChild(1) as! EmphasisNode
            let equation = paragraph.getChild(2) as! EquationNode

            let paragraphProperties = paragraph.getProperties(with: styleSheet)
            let emphasisProperties = emphasis.getProperties(with: styleSheet)
            let equationProperties = equation.getProperties(with: styleSheet)

            #expect(paragraphProperties.isEmpty)

            #expect(emphasisProperties[TextProperty.font] == nil)
            #expect(emphasisProperties[TextProperty.style] == .fontStyle(.italic))

            #expect(equationProperties[MathProperty.font] == nil)
            #expect(equationProperties[MathProperty.style] == .mathStyle(.text))
        }
    }
}
