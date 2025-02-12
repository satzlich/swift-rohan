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
@Suite(.serialized)
struct DeletionTests {
  static func setUp(_ rootNode: RootNode) -> DocumentManager {
    let documentManager = DocumentManager(StyleSheetTests.sampleStyleSheet(), rootNode)
    documentManager.textContainer = {
      let size = CGSize(width: 250, height: 0)
      return NSTextContainer(size: size)
    }()
    return documentManager
  }

  private let folderName: String

  init() throws {
    self.folderName = String("\(type(of: self))")
    try TestUtils.touchDirectory(folderName)
  }

  // function for outputting PDF
  func outputPDF(_ fileName: String, _ documentManager: DocumentManager) throws {
    try TestUtils.outputPDF(
      folderName: folderName, fileName, CGSize(width: 270, height: 200), documentManager)
  }

  @Test
  func testSharedPart() throws {
    func setUp() -> DocumentManager {
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
      let documentManager = setUp()
      // output initial
      try outputPDF("1__", documentManager)

      // check document
      #expect(
        documentManager.prettyPrint() == """
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
      try! documentManager.replaceContents(in: textRange, with: " gaily")
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
           └ paragraph
              └ text "The quick brown fox jumps gaily."
          """)
      // output
      try outputPDF("1_i", documentManager)
      #expect(documentManager.isDirty == false)
    }

    // opaque
    do {
      let documentManager = setUp()
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
      try! documentManager.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
           └ paragraph
              ├ text "The quick brown fox jumps over the"
              ├ emphasis
              └ text " dog."
          """)
      // output
      try outputPDF("1_ii", documentManager)
      #expect(documentManager.isDirty == false)
    }
  }

  @Test
  func testBranchingPart_a() throws {
    func setUp() -> DocumentManager {
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
      let documentManager  = setUp()
      // output initial
      try outputPDF("2_a__", documentManager)

      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let textRange = RhTextRange(
        TextLocation(path, " ".count),
        TextLocation(path, " Second".count))!
      try! documentManager.replaceContents(in: textRange, with: "2nd")
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
           └ heading
              ├ text "Newton's"
              ├ emphasis
              │  └ text " 2nd"
              └ text " Law of Motion"
          """)

      try outputPDF("2_a_1", documentManager)
      #expect(documentManager.isDirty == false)
    }
    // element node
    do {
      let documentManager = setUp()
      let path: [RohanIndex] = [
        .index(0)  // heading
      ]
      let textRange = RhTextRange(TextLocation(path, 1), TextLocation(path, 2))!
      try! documentManager.replaceContents(in: textRange, with: " Second")
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
           └ heading
              └ text "Newton's Second Law of Motion"
          """)

      try outputPDF("2_a_2", documentManager)
      #expect(documentManager.isDirty == false)
    }
  }

  @Test
  func testBranchingPart_b() throws {
    func setUp() -> DocumentManager {
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
      let documentManager = setUp()
      // output initial
      try outputPDF("2_b__", documentManager)

      try documentManager.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        documentManager.prettyPrint() == """
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
      try outputPDF("2_b_1", documentManager)
      #expect(documentManager.isDirty == false)
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
      let documentManager = setUp()
      try documentManager.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        documentManager.prettyPrint() == """
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
      try outputPDF("2_b_2", documentManager)
      #expect(documentManager.isDirty == false)
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
      let documentManager = setUp()
      try documentManager.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        documentManager.prettyPrint() == """
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
      try outputPDF("2_b_3", documentManager)
      #expect(documentManager.isDirty == false)
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
      let documentManager = setUp()
      try documentManager.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        documentManager.prettyPrint() == """
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
      try outputPDF("2_b_4", documentManager)
      #expect(documentManager.isDirty == false)
    }
  }

  @Test
  func testRemainderMergeable() throws {
    func setUp() -> DocumentManager {
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

    do {
      let documentManager = setUp()
      // output initial
      try outputPDF("3__", documentManager)
    }
    for (i, j) in indices {
      let documentManager = setUp()
      let textRange = RhTextRange(
        TextLocation(path, offsets[i]), TextLocation(endPath, endOffsets[j]))!
      try documentManager.replaceContents(in: textRange, with: nil)
      #expect(documentManager.prettyPrint() == expected[i][j], "i=\(i), j=\(j)")
      try outputPDF("3_\(names[i])_\(names[j])", documentManager)
      #expect(documentManager.isDirty == false)
    }
  }

  @Test
  func regress_removeTextRange() throws {  // regress incorrect use of `isForked(...)`
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          TextNode("Alpha "),
          EquationNode(
            isBlock: false,
            [
              FractionNode([TextNode("m+n")], [TextNode("n")]),
              TextNode("-c>100"),
            ]
          ),
        ])
    ])
    let documentManager = DeletionTests.setUp(rootNode)
    #expect(
      documentManager.prettyPrint() == """
        root
         └ heading
            ├ text "Alpha "
            └ equation
               └ nucleus
                  ├ fraction
                  │  ├ numerator
                  │  │  └ text "m+n"
                  │  └ denominator
                  │     └ text "n"
                  └ text "-c>100"
        """)
    do {
      let path: [RohanIndex] = [
        .index(0),
        .index(1),
        .mathIndex(.nucleus),
      ]
      let textRange = RhTextRange(TextLocation(path, 0), TextLocation(path, 1))!
      try documentManager.replaceContents(in: textRange, with: nil)
    }

    #expect(
      documentManager.prettyPrint() == """
        root
         └ heading
            ├ text "Alpha "
            └ equation
               └ nucleus
                  └ text "-c>100"
        """)
  }
}
