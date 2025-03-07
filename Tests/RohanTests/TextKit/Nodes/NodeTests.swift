// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

struct NodeTests {
  // MARK: - Children

  /** insert and remove child */
  @Test
  static func test_insertChild_removeChild_1() {
    let root = RootNode([
      ParagraphNode([
        TextNode("01")
      ]),
      ParagraphNode([
        TextNode("23")
      ]),
      ParagraphNode([
        TextNode("45")
      ]),
    ])

    #expect(
      root.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "01"
        ├ paragraph
        │ └ text "23"
        └ paragraph
          └ text "45"
        """)

    #expect(
      root.layoutLengthSynopsis() == """
        root 8
        ├ paragraph 2
        │ └ text 2
        ├ paragraph 2
        │ └ text 2
        └ paragraph 2
          └ text 2
        """)

    // insert child
    let newParagraph = ParagraphNode([TextNode("X")])
    root.insertChild(newParagraph, at: 1)
    #expect(newParagraph.parent === root)

    // check
    #expect(
      root.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "01"
        ├ paragraph
        │ └ text "X"
        ├ paragraph
        │ └ text "23"
        └ paragraph
          └ text "45"
        """)
    #expect(
      root.layoutLengthSynopsis() == """
        root 10
        ├ paragraph 2
        │ └ text 2
        ├ paragraph 1
        │ └ text 1
        ├ paragraph 2
        │ └ text 2
        └ paragraph 2
          └ text 2
        """)

    // remove child
    root.removeChild(at: 2)
    #expect(
      root.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "01"
        ├ paragraph
        │ └ text "X"
        └ paragraph
          └ text "45"
        """)
    #expect(
      root.layoutLengthSynopsis() == """
        root 7
        ├ paragraph 2
        │ └ text 2
        ├ paragraph 1
        │ └ text 1
        └ paragraph 2
          └ text 2
        """)
  }

  /** insert and remove grandchild */
  @Test
  static func test_insertChild_removeChild_2() {
    let root = RootNode([
      ParagraphNode([
        TextNode("01")
      ]),
      ParagraphNode([
        TextNode("23")
      ]),
      ParagraphNode([
        TextNode("45")
      ]),
    ])

    // insert grandchild
    let newText = TextNode("X")
    (root.getChild(1) as! ParagraphNode).insertChild(newText, at: 1)

    #expect(
      root.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "01"
        ├ paragraph
        │ ├ text "23"
        │ └ text "X"
        └ paragraph
          └ text "45"
        """)
    #expect(
      root.layoutLengthSynopsis() == """
        root 9
        ├ paragraph 2
        │ └ text 2
        ├ paragraph 3
        │ ├ text 2
        │ └ text 1
        └ paragraph 2
          └ text 2
        """)

    // remove grandchild
    (root.getChild(1) as! ParagraphNode).removeChild(at: 0)

    #expect(
      root.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "01"
        ├ paragraph
        │ └ text "X"
        └ paragraph
          └ text "45"
        """)
    #expect(
      root.layoutLengthSynopsis() == """
        root 7
        ├ paragraph 2
        │ └ text 2
        ├ paragraph 1
        │ └ text 1
        └ paragraph 2
          └ text 2
        """)

  }

  @Test
  static func test_deepCopy_insertChild() {
    let root = RootNode([
      ParagraphNode([
        TextNode("01")
      ]),
      ParagraphNode([
        TextNode("2"),
        EmphasisNode([
          TextNode("3")
        ]),
      ]),
      ParagraphNode([
        TextNode("45")
      ]),
    ])

    let newParagraph = (root.getChild(1) as! ParagraphNode).deepCopy()
    #expect(newParagraph.parent == nil)
    #expect(
      newParagraph.prettyPrint() == """
        paragraph
        ├ text "2"
        └ emphasis
          └ text "3"
        """)

    (newParagraph.getChild(1) as! EmphasisNode).insertChild(TextNode("X"), at: 1)

    // check new paragraph
    #expect(
      newParagraph.prettyPrint() == """
        paragraph
        ├ text "2"
        └ emphasis
          ├ text "3"
          └ text "X"
        """)

    // insert to new root
    root.insertChild(newParagraph, at: 3)
    #expect(
      root.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "01"
        ├ paragraph
        │ ├ text "2"
        │ └ emphasis
        │   └ text "3"
        ├ paragraph
        │ └ text "45"
        └ paragraph
          ├ text "2"
          └ emphasis
            ├ text "3"
            └ text "X"
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
    #expect(
      paragraph.prettyPrint() == """
        paragraph
        ├ text "0"
        ├ text "1"
        ├ text "2"
        └ text "3"
        """)

    do {
      let compacted = paragraph.compactSubrange(1..<3, inContentStorage: false)
      #expect(compacted == true)
      #expect(
        paragraph.prettyPrint() == """
          paragraph
          ├ text "0"
          ├ text "12"
          └ text "3"
          """)
    }

    do {
      let compacted = paragraph.compactSubrange(
        0..<paragraph.childCount,
        inContentStorage: false)
      #expect(compacted == true)
      #expect(
        paragraph.prettyPrint() == """
          paragraph
          └ text "0123"
          """)
    }

    do {
      let compacted = paragraph.compactSubrange(
        0..<paragraph.childCount,
        inContentStorage: false)
      #expect(compacted == false)
      #expect(
        paragraph.prettyPrint() == """
          paragraph
          └ text "0123"
          """)
    }
  }

  // MARK: - Length & Location

  @Test
  static func test_layoutLength() {
    let root = RootNode([
      HeadingNode(
        level: 1,
        [
          TextNode("abc"),
          EmphasisNode([TextNode("def😀")]),
        ]
      ),
      ParagraphNode([
        TextNode("hijk"),
        EquationNode(
          isBlock: false,
          [TextNode("a+b")]
        ),
      ]),
    ])

    #expect(
      root.layoutLengthSynopsis() == """
        root 14
        ├ heading 8
        │ ├ text 3
        │ └ emphasis 5
        │   └ text 5
        └ paragraph 5
          ├ text 4
          └ equation 1
            └ nucleus 3
              └ text 3
        """)

    ((root.getChild(1) as! ParagraphNode)
      .getChild(1) as! EquationNode)
      .nucleus
      .insertChild(TextNode("X"), at: 1)

    #expect(
      root.layoutLengthSynopsis() == """
        root 14
        ├ heading 8
        │ ├ text 3
        │ └ emphasis 5
        │   └ text 5
        └ paragraph 5
          ├ text 4
          └ equation 1
            └ nucleus 4
              ├ text 3
              └ text 1
        """)

  }
}
