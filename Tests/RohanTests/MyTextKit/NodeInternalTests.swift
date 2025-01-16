// Copyright 2024-2025 Lie Yan

@testable import Rohan
import AppKit
import Foundation
import Testing

struct NodeInternalTests {
    @Test
    static func testCOW() {
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

        // check initial
        let rootSynopsis = "0|1|2|3|4|5"
        let rootLengthSummary =
            """
            (6, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
            """
        #expect(root.getChild(0).parent === root)
        #expect(root.synopsis() == rootSynopsis)
        #expect(root.lengthSummary().description == rootLengthSummary)

        // insert child
        do {
            // copy new root
            let newRoot = root.copy()
            #expect(newRoot.getChild(0, ensureUnique: false).parent === root)
            #expect(newRoot.getChild(0, ensureUnique: true).parent === newRoot)
            #expect(newRoot.getChild(0, ensureUnique: false).parent === newRoot)

            // insert new paragraph
            let newParagraph = ParagraphNode([TextNode("X")])
            newRoot.insertChild(newParagraph, at: 1)
            #expect(newParagraph.parent === newRoot)

            // check
            #expect(newRoot.synopsis() == "0|1|X|2|3|4|5")
            #expect(newRoot.lengthSummary().description ==
                """
                (7, [(2, [`1`, `1`]), (1, [`1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
                """)

            #expect(root.synopsis() == rootSynopsis)
            #expect(root.lengthSummary().description == rootLengthSummary)
        }

        // insert grandchild
        do {
            let newText = TextNode("X")
            let newRoot = root.copy()
            (newRoot.getChild(1) as! ParagraphNode).insertChild(newText, at: 1)

            #expect(newRoot.synopsis() == "0|1|2|X|3|4|5")
            #expect(newRoot.lengthSummary().description ==
                """
                (7, [(2, [`1`, `1`]), (3, [`1`, `1`, `1`]), (2, [`1`, `1`])])
                """)

            #expect(root.synopsis() == rootSynopsis)
            #expect(root.lengthSummary().description == rootLengthSummary)
        }
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

        // check initial
        let rootSynopsis = "0|1|2|3|4|5"
        let rootLengthSummary =
            """
            (6, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
            """
        #expect(root.getChild(0).parent === root)
        #expect(root.synopsis() == rootSynopsis)
        #expect(root.lengthSummary().description == rootLengthSummary)

        // copy to segment
        var segment: [Node] = []
        guard let paragraph = root.getChild(1) as? ParagraphNode
        else { #expect(Bool(false)); return }
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
        #expect(newParagraph.lengthSummary().description ==
            """
            (2, [`1`, `1`])
            """)
        // check old root
        #expect(root.getChild(0).parent === root)
        #expect(root.synopsis() == rootSynopsis)
        #expect(root.lengthSummary().description == rootLengthSummary)

        // insert to new root
        let newRoot = root.copy()
        newRoot.insertChild(newParagraph, at: 3)
        #expect(newRoot.synopsis() ==
            """
            0|1|2|3|4|5|3|X
            """)
        #expect(newRoot.lengthSummary().description ==
            """
            (8, [(2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`]), (2, [`1`, `1`])])
            """)

        // check old root
        #expect(root.getChild(0).parent === root)
        #expect(root.synopsis() == rootSynopsis)
        #expect(root.lengthSummary().description == rootLengthSummary)
    }
}
