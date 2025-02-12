// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import Foundation
import Testing

@testable import Rohan

/**
 Test deletion

 ## Test Cases

 ### 1 Shared part

 1.i) free of opaque nodes \
 1.ii) contains opaque nodes

 ### 2 Branching part

 2.a) both paths into the same node:

 |        | path         | endPath      |
 |--------|--------------|--------------|
 | 2.a.1) | text node    | text node    |
 | 2.a.2) | element node | element node |

 2.b) two paths into different nodes:

 |        | path         | endPath      |
 |--------|--------------|--------------|
 | 2.b.1) | text node    | text node    |
 | 2.b.2) | text node    | element node |
 | 2.b.3) | element node | text node    |
 | 2.b.4) | element node | element node |

 ### 3 Remainder mergeable

 | remainder | path      | endPath   |
 |-----------|-----------|-----------|
 | 3.1)      | left-end  | left-end  |
 | 3.2)      | left-end  | middle    |
 | 3.3)      | left-end  | right-end |
 | 3.4)      | middle    | left-end  |
 | 3.5)      | middle    | middle    |
 | 3.6)      | middle    | right-end |
 | 3.7)      | right-end | left-end  |
 | 3.8)      | right-end | middle    |
 | 3.9)      | right-end | right-end |
 */
struct DeletionTests {
  static func setUp(_ rootNode: RootNode) -> (ContentStorage, LayoutManager) {
    // create content storage and layout manager
    let contentStorage = ContentStorage(rootNode)
    let layoutManager = LayoutManager(StyleSheetTests.sampleStyleSheet())

    // set up text container
    let pageSize = CGSize(width: 250, height: 200)
    layoutManager.textContainer = NSTextContainer(size: CGSize(width: pageSize.width, height: 0))

    // set up layout manager
    contentStorage.setLayoutManager(layoutManager)
    return (contentStorage, layoutManager)
  }

  // function for outputting PDF
  static func outputPDF(
    _ fileName: String, _ contentStorage: ContentStorage, _ layoutManager: LayoutManager
  ) throws {
    let folderName = "DeletionTests"
    try TestUtils.createDirectoryIfNotExists(folderName)
    try TestUtils.outputPDF(
      folderName: folderName, fileName, CGSize(width: 270, height: 200), layoutManager)
    #expect(contentStorage.rootNode.isDirty == false)
  }

  @Test
  static func testSharedPart() throws {
    func setUp() -> (ContentStorage, LayoutManager) {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("The quick brown fox jumps over the"),
          EmphasisNode([TextNode(" lazy")]),
          TextNode(" dog."),
        ])
      ])
      return DeletionTests.setUp(rootNode)
    }

    do {
      let (contentStorage, layoutManager) = setUp()
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           └ paragraph
              ├ text "The quick brown fox jumps over the"
              ├ emphasis
              │  └ text " lazy"
              └ text " dog."
          """)
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let endPath: [RohanIndex] = [
        .index(0),  // paragraph
        .index(2),  // text
      ]
      let textRange = RhTextRange(
        TextLocation(path, "The quick brown fox jumps".count),
        TextLocation(endPath, " dog".count))!
      // replace
      try! contentStorage.replaceContents(in: textRange, with: " gaily")
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           └ paragraph
              └ text "The quick brown fox jumps gaily."
          """)
      // output
      try outputPDF("1_i", contentStorage, layoutManager)
    }

    // opaque
    do {
      let (contentStorage, layoutManager) = setUp()
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let endPath: [RohanIndex] = [
        .index(0),  // paragraph
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let textRange = RhTextRange(
        TextLocation(path, 0),
        TextLocation(endPath, " lazy".count))!
      // replace
      try! contentStorage.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           └ paragraph
              ├ text "The quick brown fox jumps over the"
              ├ emphasis
              └ text " dog."
          """)
      // output
      try outputPDF("1_ii", contentStorage, layoutManager)
    }
  }

  @Test
  static func testBranchingPart_a() throws {
    func setUp() -> (ContentStorage, LayoutManager) {
      let rootNode = RootNode([
        HeadingNode(
          level: 1,
          [
            TextNode("Newton's"),
            EmphasisNode([TextNode(" Second")]),
            TextNode(" Law of Motion"),
          ])
      ])
      return DeletionTests.setUp(rootNode)
    }

    // text node
    do {
      let (contentStorage, layoutManager) = setUp()
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let textRange = RhTextRange(
        TextLocation(path, " ".count),
        TextLocation(path, " Second".count))!
      try! contentStorage.replaceContents(in: textRange, with: "2nd")
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           └ heading
              ├ text "Newton's"
              ├ emphasis
              │  └ text " 2nd"
              └ text " Law of Motion"
          """)

      try outputPDF("2_a_1", contentStorage, layoutManager)
    }
    // element node
    do {
      let (contentStorage, layoutManager) = setUp()
      let path: [RohanIndex] = [
        .index(0)  // heading
      ]
      let textRange = RhTextRange(TextLocation(path, 1), TextLocation(path, 2))!
      try! contentStorage.replaceContents(in: textRange, with: " Second")
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           └ heading
              └ text "Newton's Second Law of Motion"
          """)

      try outputPDF("2_a_2", contentStorage, layoutManager)
    }
  }

  @Test
  static func testBranchingPart_b() throws {
    func setUp() -> (ContentStorage, LayoutManager) {
      let rootNode = RootNode([
        HeadingNode(
          level: 1,
          [
            TextNode("Newton's"),
            EmphasisNode([TextNode(" Second")]),
            TextNode(" Law of Motion"),
          ]),
        ParagraphNode([
          TextNode("The law states:"),
          EquationNode(
            isBlock: true,
            [
              TextNode("F=m"),
              FractionNode([TextNode("dv")], [TextNode("dt")]),
              TextNode("."),
            ]),
        ]),
      ])
      return DeletionTests.setUp(rootNode)
    }

    // (text, text)
    do {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // text
      ]
      let endPath: [RohanIndex] = [
        .index(0),  // heading
        .index(2),  // text
      ]
      let textRange = RhTextRange(
        TextLocation(path, "N".count), TextLocation(endPath, " Law of M".count))!
      let (contentStorage, layoutManager) = setUp()
      try contentStorage.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           ├ heading
           │  └ text "Notion"
           └ paragraph
              ├ text "The law states:"
              └ equation
                 └ nucleus
                    ├ text "F=m"
                    ├ fraction
                    │  ├ numerator
                    │  │  └ text "dv"
                    │  └ denominator
                    │     └ text "dt"
                    └ text "."
          """)
      try outputPDF("2_b_1", contentStorage, layoutManager)
    }
    // (text, element)
    do {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // text
      ]
      let endPath: [RohanIndex] = [
        .index(0)  // heading
      ]
      let textRange = RhTextRange(
        TextLocation(path, "Newton".count), TextLocation(endPath, 3))!
      let (contentStorage, layoutManager) = setUp()
      try contentStorage.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           ├ heading
           │  └ text "Newton"
           └ paragraph
              ├ text "The law states:"
              └ equation
                 └ nucleus
                    ├ text "F=m"
                    ├ fraction
                    │  ├ numerator
                    │  │  └ text "dv"
                    │  └ denominator
                    │     └ text "dt"
                    └ text "."
          """)
      try outputPDF("2_b_2", contentStorage, layoutManager)
    }
    // (element, text)
    do {
      let path: [RohanIndex] = [
        .index(0)  // heading
      ]
      let endPath: [RohanIndex] = [
        .index(0),  // heading
        .index(2),  // text
      ]
      let textRange = RhTextRange(
        TextLocation(path, 0), TextLocation(endPath, " Law of ".count))!
      let (contentStorage, layoutManager) = setUp()
      try contentStorage.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           ├ heading
           │  └ text "Motion"
           └ paragraph
              ├ text "The law states:"
              └ equation
                 └ nucleus
                    ├ text "F=m"
                    ├ fraction
                    │  ├ numerator
                    │  │  └ text "dv"
                    │  └ denominator
                    │     └ text "dt"
                    └ text "."
          """)
      try outputPDF("2_b_3", contentStorage, layoutManager)
    }
    // (element, element-text)
    do {
      let path: [RohanIndex] = []
      let endPath: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let textRange = RhTextRange(
        TextLocation(path, 0), TextLocation(endPath, "The law states:".count))!
      let (contentStorage, layoutManager) = setUp()
      try contentStorage.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        contentStorage.rootNode.prettyPrint() == """
          root
           └ paragraph
              └ equation
                 └ nucleus
                    ├ text "F=m"
                    ├ fraction
                    │  ├ numerator
                    │  │  └ text "dv"
                    │  └ denominator
                    │     └ text "dt"
                    └ text "."
          """)
      try outputPDF("2_b_4", contentStorage, layoutManager)
    }
  }

  @Test
  static func testRemainderMergeable() throws {
    func setUp() -> (ContentStorage, LayoutManager) {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("Hello Wolrd")]),
        ParagraphNode([
          TextNode("Mary has a little lamb.")
        ]),
        ParagraphNode([
          TextNode("May the force be with you.")
        ]),
        ParagraphNode([
          TextNode("Veni. Vedi. Veci.")
        ]),
        ParagraphNode([
          TextNode("All I want is freedom. A world with no more night.")
        ]),
      ])
      return DeletionTests.setUp(rootNode)
    }
    let path: [RohanIndex] = [
      .index(1),  // paragraph
      .index(0),  // text
    ]
    let endPath: [RohanIndex] = [
      .index(3),  // paragraph
      .index(0),  // text
    ]
    let text = "Mary has a little lamb."
    let endText = "Veni. Vedi. Veci."

    let indices = product([0, 1, 2], [0, 1, 2])
    let offsets = [0, "Mary".count, text.count]
    let endOffsets = [0, "Veni.".count, endText.count]
    let names = ["left", "middle", "right"]

    let expected: [[String]] = [
      [
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         │  └ text "Veni. Vedi. Veci."
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         │  └ text " Vedi. Veci."
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
      ],
      [
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         │  └ text "MaryVeni. Vedi. Veci."
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         │  └ text "Mary Vedi. Veci."
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         │  └ text "Mary"
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
      ],
      [
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         │  └ text "Mary has a little lamb.Veni. Vedi. Veci."
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         │  └ text "Mary has a little lamb. Vedi. Veci."
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
         ├ heading
         │  └ text "Hello Wolrd"
         ├ paragraph
         │  └ text "Mary has a little lamb."
         └ paragraph
            └ text "All I want is freedom. A world with no more night."
        """,
      ],
    ]

    for (i, j) in indices {
      let (contentStorage, layoutManager) = setUp()
      let textRange = RhTextRange(
        TextLocation(path, offsets[i]), TextLocation(endPath, endOffsets[j]))!
      try contentStorage.replaceContents(in: textRange, with: nil)
      #expect(contentStorage.rootNode.prettyPrint() == expected[i][j], "\(i),\(j)")
      try outputPDF("3_\(names[i])_\(names[j])", contentStorage, layoutManager)
    }
  }
}
