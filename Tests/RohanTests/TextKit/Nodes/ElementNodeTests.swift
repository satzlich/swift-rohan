// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct ElementNodeTests {
    @Test
    static func test_getProperties() {
        let styleSheet = StyleSheetTests.sampleStyleSheet()

        do {
            let emphasis = EmphasisNode([TextNode("ab😀")])
            let heading = HeadingNode(level: 1, [emphasis])
            do {
                let properties = heading.getProperties(styleSheet)
                #expect(properties[TextProperty.style] == .fontStyle(.italic))
            }
            do {
                let properties = emphasis.getProperties(styleSheet)
                #expect(properties[TextProperty.style] == .fontStyle(.normal))
            }
        }

        do {
            let emphasis = EmphasisNode([TextNode("cd😀")])
            let paragraph = ParagraphNode([emphasis])
            do {
                let properties = emphasis.getProperties(styleSheet)
                #expect(properties[TextProperty.font] == nil)
                #expect(properties[TextProperty.style] == .fontStyle(.italic))
            }
            do {
                let properties = paragraph.getProperties(styleSheet)
                #expect(properties.isEmpty)
            }
        }
    }

    @Test
    static func test_isBlock() {
        let heading = HeadingNode(level: 1, [TextNode("abc")])
        #expect(heading.isBlock == false)

        let paragraph = ParagraphNode([TextNode("abc")])
        #expect(paragraph.isBlock == false)
    }

    /** intrinsic length, extrinsic length, and layout length */
    @Test
    static func testLength() {
        let emphasis = EmphasisNode([
            TextNode("a😀b"),
            EquationNode(isBlock: true, [TextNode("a+b")]),
        ])
        #expect(emphasis.intrinsicLength == 4)
        #expect(emphasis.extrinsicLength == 1)
        #expect(emphasis.layoutLength == 6)

        let heading = HeadingNode(level: 1, [
            TextNode("a😀b"),
            EquationNode(isBlock: true, [TextNode("a+b")]),
        ])
        #expect(heading.intrinsicLength == 4)
        #expect(heading.extrinsicLength == 1)
        #expect(heading.layoutLength == 6)

        let paragraph = ParagraphNode([
            TextNode("a😀b"),
            EquationNode(isBlock: false, [TextNode("a+b")]),
        ])
        #expect(paragraph.intrinsicLength == 4)
        #expect(paragraph.extrinsicLength == 4)
        #expect(paragraph.layoutLength == 5)

        let root = RootNode([
            ParagraphNode([
                TextNode("a😀b"),
                EquationNode(isBlock: false, [TextNode("a+b")]),
            ]),
            LinebreakNode(),
        ])
        #expect(root.intrinsicLength == 5)
        #expect(root.extrinsicLength == 5)
        #expect(root.layoutLength == 6)
    }
}
