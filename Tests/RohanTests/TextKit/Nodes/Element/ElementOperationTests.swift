// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ElementOperationTests {

  /// insert and remove child
  @Test
  static func insertChild_removeChild_1() {
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

    TestUtils.updateLayoutLength(root)
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
    root.insertChild(newParagraph, at: 1, inStorage: false)
    #expect(newParagraph.parent === root)
    TestUtils.updateLayoutLength(root)

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
    root.removeChild(at: 2, inStorage: false)
    TestUtils.updateLayoutLength(root)
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

  /// insert and remove grandchild
  @Test
  static func insertChild_removeChild_2() {
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
    (root.getChild(1) as! ParagraphNode).insertChild(newText, at: 1, inStorage: false)
    TestUtils.updateLayoutLength(root)

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
    (root.getChild(1) as! ParagraphNode).removeChild(at: 0, inStorage: false)
    TestUtils.updateLayoutLength(root)

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
  static func deepCopy_insertChild() {
    let root = RootNode([
      ParagraphNode([
        TextNode("01")
      ]),
      ParagraphNode([
        TextNode("2"),
        TextStylesNode(
          .emph,
          [
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
        └ emph
          └ text "3"
        """)

    (newParagraph.getChild(1) as! TextStylesNode)
      .insertChild(TextNode("X"), at: 1, inStorage: false)

    // check new paragraph
    #expect(
      newParagraph.prettyPrint() == """
        paragraph
        ├ text "2"
        └ emph
          ├ text "3"
          └ text "X"
        """)

    // insert to new root
    root.insertChild(newParagraph, at: 3, inStorage: false)
    #expect(
      root.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "01"
        ├ paragraph
        │ ├ text "2"
        │ └ emph
        │   └ text "3"
        ├ paragraph
        │ └ text "45"
        └ paragraph
          ├ text "2"
          └ emph
            ├ text "3"
            └ text "X"
        """)
  }

  // MARK: - Length & Location

  @Test
  static func layoutLength() {
    let root = RootNode([
      HeadingNode(
        .sectionAst,
        [
          TextNode("abc"),
          TextStylesNode(.emph, [TextNode("def😀")]),
        ]
      ),
      ParagraphNode([
        TextNode("hijk"),
        EquationNode(.inline, [TextNode("a+b")]),
      ]),
    ])
    TestUtils.updateLayoutLength(root)

    do {
      let expected =
        """
        root 15
        ├ heading 8
        │ ├ text 3
        │ └ emph 5
        │   └ text 5
        └ paragraph 6
          ├ text 4
          └ equation 2
            └ nuc 3
              └ text 3
        """
      #expect(root.layoutLengthSynopsis() == expected)
    }

    ((root.getChild(1) as! ParagraphNode)
      .getChild(1) as! EquationNode)
      .nucleus
      .insertChild(TextNode("X"), at: 1, inStorage: false)
    TestUtils.updateLayoutLength(root)

    do {
      let expected =
        """
        root 15
        ├ heading 8
        │ ├ text 3
        │ └ emph 5
        │   └ text 5
        └ paragraph 6
          ├ text 4
          └ equation 2
            └ nuc 4
              ├ text 3
              └ text 1
        """
      #expect(root.layoutLengthSynopsis() == expected)
    }
  }
}
