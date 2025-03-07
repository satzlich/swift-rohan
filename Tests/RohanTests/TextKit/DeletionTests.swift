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
final class DeletionTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func testSharedPart() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("The quick brown fox jumps over the"),
          EmphasisNode([TextNode(" lazy")]),
          TextNode(" dog."),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    do {
      let documentManager = createDocumentManager()

      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
          └ paragraph
            ├ text "The quick brown fox jumps over the"
            ├ emphasis
            │ └ text " lazy"
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
      try! documentManager.replaceCharacters(in: textRange, with: " gaily")
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
          └ paragraph
            └ text "The quick brown fox jumps gaily."
          """)
    }

    // opaque
    do {
      let documentManager = createDocumentManager()
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
    }
  }

  @Test
  func testBranchingPart_a() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        HeadingNode(
          level: 1,
          [
            TextNode("Newton's"),
            EmphasisNode([TextNode(" Second")]),
            TextNode(" Law of Motion"),
          ])
      ])
      return self.createDocumentManager(rootNode)
    }

    // text node
    do {
      let documentManager = createDocumentManager()

      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let textRange = RhTextRange(
        TextLocation(path, " ".count),
        TextLocation(path, " Second".count))!
      try! documentManager.replaceCharacters(in: textRange, with: "2nd")
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
          └ heading
            ├ text "Newton's"
            ├ emphasis
            │ └ text " 2nd"
            └ text " Law of Motion"
          """)
    }
    // element node
    do {
      let documentManager = createDocumentManager()
      let path: [RohanIndex] = [
        .index(0)  // heading
      ]
      let textRange = RhTextRange(TextLocation(path, 1), TextLocation(path, 2))!
      try! documentManager.replaceCharacters(in: textRange, with: " Second")
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
          └ heading
            └ text "Newton's Second Law of Motion"
          """)
    }
  }

  @Test
  func testBranchingPart_b() throws {
    func createDocumentManager() -> DocumentManager {
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
      return self.createDocumentManager(rootNode)
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
      let documentManager = createDocumentManager()

      try documentManager.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "Notion"
          └ paragraph
            ├ text "The law states:"
            └ equation
              └ nucleus
                ├ text "F=m"
                ├ fraction
                │ ├ numerator
                │ │ └ text "dv"
                │ └ denominator
                │   └ text "dt"
                └ text "."
          """)
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
      let documentManager = createDocumentManager()
      try documentManager.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "Newton"
          └ paragraph
            ├ text "The law states:"
            └ equation
              └ nucleus
                ├ text "F=m"
                ├ fraction
                │ ├ numerator
                │ │ └ text "dv"
                │ └ denominator
                │   └ text "dt"
                └ text "."
          """)
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
      let documentManager = createDocumentManager()
      try documentManager.replaceContents(in: textRange, with: nil)
      // check document
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "Motion"
          └ paragraph
            ├ text "The law states:"
            └ equation
              └ nucleus
                ├ text "F=m"
                ├ fraction
                │ ├ numerator
                │ │ └ text "dv"
                │ └ denominator
                │   └ text "dt"
                └ text "."
          """)
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
      let documentManager = createDocumentManager()
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
                │ ├ numerator
                │ │ └ text "dv"
                │ └ denominator
                │   └ text "dt"
                └ text "."
          """)
    }
  }

  @Test
  func testRemainderMergeable() throws {
    func createDocumentManager() -> DocumentManager {
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
      return self.createDocumentManager(rootNode)
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

    let expected: [[String]] = [
      [
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Veni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text " Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
      ],
      [
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "MaryVeni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary"
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
      ],
      [
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb.Veni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
      ],
    ]

    for (i, j) in indices {
      let documentManager = createDocumentManager()
      let textRange = RhTextRange(
        TextLocation(path, offsets[i]), TextLocation(endPath, endOffsets[j]))!
      try documentManager.replaceContents(in: textRange, with: nil)
      #expect(documentManager.prettyPrint() == expected[i][j], "i=\(i), j=\(j)")
    }
  }

  @Test
  func testApplyNode() throws {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("Sample of nested apply nodes: "),
        ApplyNode(
          TemplateSample.doubleText,
          [
            [ApplyNode(TemplateSample.doubleText, [[TextNode("foxpro")]])!]
          ])!,
      ]),
      HeadingNode(
        level: 1,
        [
          EquationNode(
            isBlock: false,
            [
              TextNode("m+"),
              ApplyNode(
                TemplateSample.complexFraction, [[TextNode("x")], [TextNode("1+y")]])!,
              TextNode("+n"),
            ])
        ]),
      ParagraphNode([
        EquationNode(
          isBlock: true,
          [
            ApplyNode(
              TemplateSample.bifun,
              [
                [ApplyNode(TemplateSample.bifun, [[TextNode("n-k+1")]])!]
              ])!
          ])
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)
    do {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(1),  // apply node
        .argumentIndex(0),  // first argument
        .index(0),  // nested apply node
        .argumentIndex(0),  // first argument
        .index(0),  // text
      ]
      let offset = "fox".count
      let location = TextLocation(path, offset)
      let endOffset = offset + "pro".count
      let endLocation = TextLocation(path, endOffset)
      let textRange = RhTextRange(location, endLocation)!
      try! documentManager.replaceCharacters(in: textRange, with: "")
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // apply node
        .argumentIndex(1),  // second argument
        .index(0),  // text
      ]
      let offset = 0
      let location = TextLocation(path, offset)
      let endOffset = "1+".count
      let endLocation = TextLocation(path, endOffset)
      let textRange = RhTextRange(location, endLocation)!
      try! documentManager.replaceCharacters(in: textRange, with: "")
    }
    do {
      let path: [RohanIndex] = [
        .index(2),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // apply node
        .argumentIndex(0),  // first argument
        .index(0),  // apply node
        .argumentIndex(0),  // first argument
        .index(0),
      ]
      let offset = "n".count
      let location = TextLocation(path, offset)
      let endOffset = offset + "-k".count
      let endLocation = TextLocation(path, endOffset)
      let textRange = RhTextRange(location, endLocation)!
      try! documentManager.replaceCharacters(in: textRange, with: "")
    }

    #expect(
      documentManager.prettyPrint() == """
        root
        ├ paragraph
        │ ├ text "Sample of nested apply nodes: "
        │ └ template(doubleText)
        │   ├ argument #0 (x2)
        │   └ content
        │     ├ text "{"
        │     ├ variable #0
        │     │ └ template(doubleText)
        │     │   ├ argument #0 (x2)
        │     │   └ content
        │     │     ├ text "{"
        │     │     ├ variable #0
        │     │     │ └ text "fox"
        │     │     ├ text " and "
        │     │     ├ emphasis
        │     │     │ └ variable #0
        │     │     │   └ text "fox"
        │     │     └ text "}"
        │     ├ text " and "
        │     ├ emphasis
        │     │ └ variable #0
        │     │   └ template(doubleText)
        │     │     ├ argument #0 (x2)
        │     │     └ content
        │     │       ├ text "{"
        │     │       ├ variable #0
        │     │       │ └ text "fox"
        │     │       ├ text " and "
        │     │       ├ emphasis
        │     │       │ └ variable #0
        │     │       │   └ text "fox"
        │     │       └ text "}"
        │     └ text "}"
        ├ heading
        │ └ equation
        │   └ nucleus
        │     ├ text "m+"
        │     ├ template(complexFraction)
        │     │ ├ argument #0 (x2)
        │     │ ├ argument #1 (x2)
        │     │ └ content
        │     │   └ fraction
        │     │     ├ numerator
        │     │     │ └ fraction
        │     │     │   ├ numerator
        │     │     │   │ ├ variable #1
        │     │     │   │ │ └ text "y"
        │     │     │   │ └ text "+1"
        │     │     │   └ denominator
        │     │     │     ├ variable #0
        │     │     │     │ └ text "x"
        │     │     │     └ text "+1"
        │     │     └ denominator
        │     │       ├ variable #0
        │     │       │ └ text "x"
        │     │       ├ text "+"
        │     │       ├ variable #1
        │     │       │ └ text "y"
        │     │       └ text "+1"
        │     └ text "+n"
        └ paragraph
          └ equation
            └ nucleus
              └ template(bifun)
                ├ argument #0 (x2)
                └ content
                  ├ text "f("
                  ├ variable #0
                  │ └ template(bifun)
                  │   ├ argument #0 (x2)
                  │   └ content
                  │     ├ text "f("
                  │     ├ variable #0
                  │     │ └ text "n+1"
                  │     ├ text ","
                  │     ├ variable #0
                  │     │ └ text "n+1"
                  │     └ text ")"
                  ├ text ","
                  ├ variable #0
                  │ └ template(bifun)
                  │   ├ argument #0 (x2)
                  │   └ content
                  │     ├ text "f("
                  │     ├ variable #0
                  │     │ └ text "n+1"
                  │     ├ text ","
                  │     ├ variable #0
                  │     │ └ text "n+1"
                  │     └ text ")"
                  └ text ")"
        """)
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
    let documentManager = createDocumentManager(rootNode)
    #expect(
      documentManager.prettyPrint() == """
        root
        └ heading
          ├ text "Alpha "
          └ equation
            └ nucleus
              ├ fraction
              │ ├ numerator
              │ │ └ text "m+n"
              │ └ denominator
              │   └ text "n"
              └ text "-c>100"
        """)
    let path: [RohanIndex] = [
      .index(0),
      .index(1),
      .mathIndex(.nucleus),
    ]
    let textRange = RhTextRange(TextLocation(path, 0), TextLocation(path, 1))!
    try documentManager.replaceContents(in: textRange, with: nil)
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
