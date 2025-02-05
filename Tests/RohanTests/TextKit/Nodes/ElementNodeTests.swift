// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct ElementNodeTests {
    @Test
    static func test_getChild_getOffset() {
        let ab = TextNode("ab😀")
        let emphasis = EmphasisNode([TextNode("c😀d")])
        let heading = HeadingNode(level: 1, [ab, emphasis])

        // use array index
        #expect(heading.getChild(.arrayIndex(0)) === ab)
        #expect(heading.getChild(.arrayIndex(1)) === emphasis)
        #expect(heading.getChild(.arrayIndex(2)) === nil)

        #expect(heading.getOffset(before: .arrayIndex(0)) == 1)
        #expect(heading.getOffset(before: .arrayIndex(1)) == 4)
        #expect(heading.getOffset(before: .arrayIndex(2)) == 9)

        // use stable offset
        #expect(heading.getChild(.stableOffset(0, true)) == nil)
        #expect(heading.getChild(.stableOffset(1, false)) == nil)
        //            #expect(heading.getChild(.stableOffset(1, true)) === ab)
        #expect(heading.getChild(.stableOffset(4, false)) == nil)
        #expect(heading.getChild(.stableOffset(4, true)) === emphasis)
        #expect(heading.getChild(.stableOffset(5, false)) === emphasis)
        #expect(heading.getChild(.stableOffset(9, false)) == nil)

        #expect(heading.getOffset(before: .stableOffset(1, true)) == 1)
        #expect(heading.getOffset(before: .stableOffset(4, true)) == 4)
        #expect(heading.getOffset(before: .stableOffset(9, true)) == 9)
    }

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
        #expect(heading.isBlock == true)

        let paragraph = ParagraphNode([TextNode("abc")])
        #expect(paragraph.isBlock == false)
    }

    @Test
    static func test_startPadding_endPadding() {
        #expect(RootNode.startPadding == false)
        #expect(RootNode.endPadding == false)
        #expect(ContentNode.startPadding == false)
        #expect(ContentNode.endPadding == false)
        #expect(ParagraphNode.startPadding == false)
        #expect(ParagraphNode.endPadding == true)
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
