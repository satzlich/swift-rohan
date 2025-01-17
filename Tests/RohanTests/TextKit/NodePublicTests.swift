// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Rohan
import Testing

struct NodePublicTests {
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
        #expect(root.synopsis() == rootSynopsis)

        // insert child
        do {
            // copy new root
            let newRoot = root.copy()

            // insert new paragraph
            let newParagraph = ParagraphNode([TextNode("X")])
            newRoot.insertChild(newParagraph, at: 1)

            // check
            #expect(newRoot.synopsis() == "0|1|X|2|3|4|5")
            #expect(root.synopsis() == rootSynopsis)
        }

        // insert grandchild
        do {
            let newText = TextNode("X")
            let newRoot = root.copy()
            (newRoot.getChild(1) as! ParagraphNode).insertChild(newText, at: 1)

            // check
            #expect(newRoot.synopsis() == "0|1|2|X|3|4|5")
            #expect(root.synopsis() == rootSynopsis)
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
        #expect(root.synopsis() == rootSynopsis)

        // copy to segment
        var segment: [Node] = []
        guard let paragraph = root.getChild(1) as? ParagraphNode
        else { #expect(Bool(false)); return }
        for i in (1 ..< paragraph.childCount()) {
            segment.append(paragraph.getChild(i))
        }

        // create new paragraph
        let newParagraph = ParagraphNode(segment)
        newParagraph.insertChild(TextNode("X"), at: 1)

        // check new paragraph
        #expect(newParagraph.synopsis() == "3|X")
        // check old root
        #expect(root.synopsis() == rootSynopsis)

        // insert to new root
        let newRoot = root.copy()
        newRoot.insertChild(newParagraph, at: 3)
        #expect(newRoot.synopsis() == "0|1|2|3|4|5|3|X")

        // check old root
        #expect(root.synopsis() == rootSynopsis)
    }
}
