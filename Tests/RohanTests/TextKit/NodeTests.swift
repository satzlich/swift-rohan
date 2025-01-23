// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct NodeTests {
    // MARK: - Children

    @Test
    static func testInsertAndRemove_1() {
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

    @Test
    static func testInsertAndRemove_2() {
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
    static func testCopyAndInsert() {
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
    static func testCompaction() {
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

    // MARK: - Styles

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

    // MARK: - Length & Location

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
            "(21, [(11, [`3`, (6, [`4`])]), (10, [`4`, (5, [(3, [`3`])])])])")
        #expect(root.nsLengthSynopsis() ==
            "(14, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(3, [`3`])])])])")

        ((root.getChild(1) as! ParagraphNode)
            .getChild(1) as! EquationNode)
            .nucleus
            .insertChild(TextNode("X"), at: 1)

        #expect(root.lengthSynopsis() ==
            "(22, [(11, [`3`, (6, [`4`])]), (11, [`4`, (6, [(4, [`3`, `1`])])])])")
        #expect(root.nsLengthSynopsis() ==
            "(14, [(8, [`3`, (5, [`5`])]), (5, [`4`, (1, [(4, [`3`, `1`])])])])")
    }

    @Test
    static func testLocation() {
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
            let (path, offset) = root.locate(0)
            #expect("\(path)" == "[0]")
            #expect(offset == nil)
            #expect(root.offset(for: path) == 0)
        }
        do {
            let (path, offset) = root.locate(4)
            #expect("\(path)" == "[0, 0]")
            #expect(offset == 3)
            #expect(root.offset(for: path + [.arrayIndex(offset!)]) == 4)
        }
        do {
            let (path, offset) = root.locate(5)
            #expect("\(path)" == "[0, 1, 0]")
            #expect(offset == 0)
            #expect(root.offset(for: path + [.arrayIndex(offset!)]) == 5)
        }
        do {
            let (path, offset) = root.locate(11)
            #expect("\(path)" == "[1, 0]")
            #expect(offset == 0)
            #expect(root.offset(for: path + [.arrayIndex(offset!)]) == 11)
        }
        do {
            let (path, offset) = root.locate(15)
            #expect("\(path)" == "[1, 0]")
            #expect(offset == 4)
            #expect(root.offset(for: path + [.arrayIndex(offset!)]) == 15)
        }
        do {
            let (path, offset) = root.locate(16)
            #expect("\(path)" == "[1, 1, nucleus, 0]")
            #expect(offset == 0)
            #expect(root.offset(for: path + [.arrayIndex(offset!)]) == 16)
        }
        do {
            let (path, offset) = root.locate(20)
            #expect("\(path)" == "[1, 2]")
            #expect(offset == nil)
            #expect(root.offset(for: path) == 20)
        }
        do {
            let (path, offset) = root.locate(21)
            #expect("\(path)" == "[2]")
            #expect(offset == nil)
            #expect(root.offset(for: path) == 21)
        }
    }
}
