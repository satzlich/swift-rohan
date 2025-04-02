// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import Foundation
import Testing
import _RopeModule

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
final class DeleteRangeTests: TextKitTestsBase {
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
      let textRange = {
        let path: [RohanIndex] = [
          .index(0),  // paragraph
          .index(0),  // text
        ]
        let endPath: [RohanIndex] = [
          .index(0),  // paragraph
          .index(2),  // text
        ]
        return RhTextRange(
          TextLocation(path, "The quick brown fox jumps".count),
          TextLocation(endPath, " dog".count))!
      }()
      let range1 = "[0↓,0↓]:25..<[0↓,0↓]:31"
      let string: BigString = " gaily"
      let doc1 = """
        root
        └ paragraph
          └ text "The quick brown fox jumps gaily."
        """
      let range2 = "[0↓,0↓]:25..<[0↓,2↓]:4"
      self.testRoundTrip(
        textRange, string, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // opaque
    do {
      let documentManager = createDocumentManager()
      let textRange = {
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
        return RhTextRange(
          TextLocation(path, 0),
          TextLocation(endPath, " lazy".count))!
      }()
      let range1 = "[0↓,1↓]:0"
      let doc1 = """
        root
        └ paragraph
          ├ text "The quick brown fox jumps over the"
          ├ emphasis
          └ text " dog."
        """
      let range2 = "[0↓,1↓,0↓]:0..<[0↓,1↓,0↓]:5"
      self.testRoundTrip(
        textRange, nil, documentManager,
        range1: range1, doc1: doc1, range2: range2)
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
      let textRange = {
        let path: [RohanIndex] = [
          .index(0),  // heading
          .index(1),  // emphasis
          .index(0),  // text
        ]
        return RhTextRange(
          TextLocation(path, " ".count),
          TextLocation(path, " Second".count))!
      }()
      let range1 = "[0↓,1↓,0↓]:1..<[0↓,1↓,0↓]:4"
      let doc1 = """
        root
        └ heading
          ├ text "Newton's"
          ├ emphasis
          │ └ text " 2nd"
          └ text " Law of Motion"
        """
      let range2 = "[0↓,1↓,0↓]:1..<[0↓,1↓,0↓]:7"
      self.testRoundTrip(
        textRange, "2nd", documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // element node
    do {
      let documentManager = createDocumentManager()
      let textRange = {
        let path: [RohanIndex] = [
          .index(0)  // heading
        ]
        return RhTextRange(TextLocation(path, 1), TextLocation(path, 2))!
      }()
      let string: BigString = " Second"
      let range1 = "[0↓,0↓]:8..<[0↓,0↓]:15"
      let doc1 = """
        root
        └ heading
          └ text "Newton's Second Law of Motion"
        """
      let range2 = "[0↓,0↓]:8..<[0↓,2↓]:0"
      self.testRoundTrip(
        textRange, string, documentManager,
        range1: range1, doc1: doc1, range2: range2)
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
            nucleus: [
              TextNode("F=m"),
              FractionNode(numerator: [TextNode("dv")], denominator: [TextNode("dt")]),
              TextNode("."),
            ]),
        ]),
      ])
      return self.createDocumentManager(rootNode)
    }

    // (text, text)
    do {
      let documentManager = createDocumentManager()
      let textRange = {
        let path: [RohanIndex] = [
          .index(0),  // heading
          .index(0),  // text
        ]
        let location = TextLocation(path, "N".count)
        let endPath: [RohanIndex] = [
          .index(0),  // heading
          .index(2),  // text
        ]
        let endLocation = TextLocation(endPath, " Law of M".count)
        return RhTextRange(location, endLocation)!
      }()
      let range1 = "[0↓,0↓]:1"
      let doc1 = """
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
        """
      let range2 = "[0↓,0↓]:1..<[0↓,2↓]:9"
      self.testRoundTrip(
        textRange, nil, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // (text, element)
    do {
      let documentManager = createDocumentManager()
      let textRange = {
        let path: [RohanIndex] = [
          .index(0),  // heading
          .index(0),  // text
        ]
        let endPath: [RohanIndex] = [
          .index(0)  // heading
        ]
        return RhTextRange(TextLocation(path, "Newton".count), TextLocation(endPath, 3))!
      }()
      let range1 = "[0↓,0↓]:6"
      let doc1 = """
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
        """
      let range2 = "[0↓,0↓]:6..<[0↓,2↓]:14"
      self.testRoundTrip(
        textRange, nil, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // (element, text)
    do {
      let documentManager = createDocumentManager()
      let textRange = {
        let path: [RohanIndex] = [
          .index(0)  // heading
        ]
        let location = TextLocation(path, 0)
        let endPath: [RohanIndex] = [
          .index(0),  // heading
          .index(2),  // text
        ]
        let endLocation = TextLocation(endPath, " Law of ".count)
        return RhTextRange(location, endLocation)!
      }()
      let range1 = "[0↓,0↓]:0"
      let doc1 = """
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
        """
      let range2 = "[0↓,0↓]:0..<[0↓,2↓]:8"
      self.testRoundTrip(
        textRange, nil, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // (element, text)
    do {
      let documentManager = createDocumentManager()
      let textRange = {
        let path: [RohanIndex] = []
        let location = TextLocation(path, 0)
        let endPath: [RohanIndex] = [
          .index(1),  // paragraph
          .index(0),  // text
        ]
        let endLocation = TextLocation(endPath, "The law states:".count)
        return RhTextRange(location, endLocation)!
      }()
      let range1 = "[0↓]:0"
      let doc1 = """
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
        """
      let range2 = "[]:0..<[1↓,0↓]:15"
      self.testRoundTrip(
        textRange, nil, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  // (text, element)
  @Test
  func testBranchingPart_2_b_2() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("the quick "),
          EmphasisNode([TextNode("brown ")]),
          TextNode("fox jumps over "),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()
    let range = {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      let endPath: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let endLocation = TextLocation(endPath, 2)
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[0↓,0↓]:0"
    let doc1 = """
      root
      └ paragraph
        └ text "fox jumps over "
      """
    let range2 = "[0↓,0↓]:0..<[0↓,2↓]:0"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  // (text, element) st. a paragraph should be removed.
  @Test
  func testBranchingPart_2_b_2_removeParagraph() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("the quick "),
          EmphasisNode([TextNode("brown ")]),
          TextNode("fox jumps over "),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()
    let range = {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      let endPath: [RohanIndex] = []
      let endLocation = TextLocation(endPath, 1)
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[]:0"
    let doc1 = """
      root
      """
    let range2 = "[0↓,0↓]:0..<[]:1"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  // (element, text)
  @Test
  func testBranchingPart_2_b_3() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("the quick "),
          EmphasisNode([TextNode("brown ")]),
          TextNode("fox jumps over "),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()
    let range = {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let location = TextLocation(path, 1)
      let endPath: [RohanIndex] = [
        .index(0),  // paragraph
        .index(2),  // text
      ]
      let endLocation = TextLocation(endPath, "fox ".count)
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[0↓,0↓]:10"
    let doc1 = """
      root
      └ paragraph
        └ text "the quick jumps over "
      """
    let range2 = "[0↓,0↓]:10..<[0↓,2↓]:4"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
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

    let offsets = [0, "Mary".count, text.count]
    let endOffsets = [0, "Veni.".count, endText.count]
    let indices = product(offsets.indices, endOffsets.indices)

    typealias ExpectedResult = (range1: String, doc1: String, range2: String)

    let results: [ExpectedResult] = [
      // i = 0
      (
        "[1↓,0↓]:0",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Veni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:0..<[3↓,0↓]:0"
      ),
      (
        "[1↓,0↓]:0",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text " Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:0..<[3↓,0↓]:5"
      ),
      (
        "[1↓]:0",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:0..<[3↓,0↓]:17"
      ),
      // i = 1
      (
        "[1↓,0↓]:4",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "MaryVeni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:4..<[3↓,0↓]:0"
      ),
      (
        "[1↓,0↓]:4",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:4..<[3↓,0↓]:5"
      ),
      (
        "[1↓,0↓]:4",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary"
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:4..<[3↓,0↓]:17"
      ),
      // i = 2
      (
        "[1↓,0↓]:23",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb.Veni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:23..<[3↓,0↓]:0"
      ),
      (
        "[1↓,0↓]:23",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:23..<[3↓,0↓]:5"
      ),
      (
        "[1↓,0↓]:23",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[1↓,0↓]:23..<[3↓,0↓]:17"
      ),
    ]

    for (i, j) in indices {
      let documentManager = createDocumentManager()
      let textRange = {
        let location = TextLocation(path, offsets[i])
        let endLocation = TextLocation(endPath, endOffsets[j])
        return RhTextRange(location, endLocation)!
      }()
      let k = i * 3 + j
      let (range1, doc1, range2) = results[k]
      self.testRoundTrip(
        textRange, nil, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  // (element_1, beginning) ~ (element_2, end)
  @Test
  func testRemainderMergeable_3_3() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EmphasisNode([TextNode("the quick ")]),
          TextNode("brown fox "),
          EmphasisNode([TextNode("jumps over ")]),
          TextNode("the lazy "),
          EmphasisNode([TextNode("dog.")]),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()
    let range = {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(1),  // text
      ]
      let location = TextLocation(path, 0)
      let endPath: [RohanIndex] = [
        .index(0),  // paragraph
        .index(3),  // text
      ]
      let endLocation = TextLocation(endPath, "the lazy ".count)
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[0↓]:1"
    let doc1 = """
      root
      └ paragraph
        ├ emphasis
        │ └ text "the quick "
        └ emphasis
          └ text "dog."
      """
    let range2 = "[0↓,1↓]:0..<[0↓,3↓]:9"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  // (element_1, middle) ~ (element_2, middle) so that text_1 and text_2 are merged
  @Test
  func testRemainderMergeable_3_5() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("the quick brown "),  // text_1
          EmphasisNode([TextNode("fox ")]),
        ]),
        ParagraphNode([
          TextNode("jumps over the lazy dog.")  // text_2
        ]),
      ])
      return self.createDocumentManager(rootNode)
    }()
    let range = {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let location = TextLocation(path, 1)
      let endPath: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let endLocation = TextLocation(endPath, "jumps over the lazy ".count)
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[0↓,0↓]:16"
    let doc1 = """
      root
      └ paragraph
        └ text "the quick brown dog."
      """
    let range2 = "[0↓,0↓]:16..<[1↓,0↓]:20"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func testApplyNode_doubleText() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("Sample of nested apply nodes: "),
          ApplyNode(
            CompiledSamples.doubleText,
            [
              [ApplyNode(CompiledSamples.doubleText, [[TextNode("foxpro")]])!]
            ])!,
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    let range = {
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
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[0↓,1↓,0⇒,0↓,0⇒,0↓]:3"
    let doc1 = """
      root
      └ paragraph
        ├ text "Sample of nested apply nodes: "
        └ template(doubleText)
          ├ argument #0 (x2)
          └ content
            ├ text "{"
            ├ variable #0
            │ └ template(doubleText)
            │   ├ argument #0 (x2)
            │   └ content
            │     ├ text "{"
            │     ├ variable #0
            │     │ └ text "fox"
            │     ├ text " and "
            │     ├ emphasis
            │     │ └ variable #0
            │     │   └ text "fox"
            │     └ text "}"
            ├ text " and "
            ├ emphasis
            │ └ variable #0
            │   └ template(doubleText)
            │     ├ argument #0 (x2)
            │     └ content
            │       ├ text "{"
            │       ├ variable #0
            │       │ └ text "fox"
            │       ├ text " and "
            │       ├ emphasis
            │       │ └ variable #0
            │       │   └ text "fox"
            │       └ text "}"
            └ text "}"
      """
    let range2 = "[0↓,1↓,0⇒,0↓,0⇒,0↓]:3..<[0↓,1↓,0⇒,0↓,0⇒,0↓]:6"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func testApplyNode_complexFraction() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(
          level: 1,
          [
            EquationNode(
              isBlock: false,
              nucleus: [
                TextNode("m+"),
                ApplyNode(
                  CompiledSamples.complexFraction, [[TextNode("x")], [TextNode("1+y")]])!,
                TextNode("+n"),
              ])
          ])
      ])
      return self.createDocumentManager(rootNode)
    }()
    let range = {
      let path: [RohanIndex] = [
        .index(0),  // heading
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
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[0↓,0↓,nucleus,1↓,1⇒,0↓]:0"
    let doc1 = """
      root
      └ heading
        └ equation
          └ nucleus
            ├ text "m+"
            ├ template(complexFraction)
            │ ├ argument #0 (x2)
            │ ├ argument #1 (x2)
            │ └ content
            │   └ fraction
            │     ├ numerator
            │     │ └ fraction
            │     │   ├ numerator
            │     │   │ ├ variable #1
            │     │   │ │ └ text "y"
            │     │   │ └ text "+1"
            │     │   └ denominator
            │     │     ├ variable #0
            │     │     │ └ text "x"
            │     │     └ text "+1"
            │     └ denominator
            │       ├ variable #0
            │       │ └ text "x"
            │       ├ text "+"
            │       ├ variable #1
            │       │ └ text "y"
            │       └ text "+1"
            └ text "+n"
      """
    let range2 = "[0↓,0↓,nucleus,1↓,1⇒,0↓]:0..<[0↓,0↓,nucleus,1↓,1⇒,0↓]:2"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func testApplyNode_bifun() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EquationNode(
            isBlock: true,
            nucleus: [
              ApplyNode(
                CompiledSamples.bifun,
                [
                  [ApplyNode(CompiledSamples.bifun, [[TextNode("n-k+1")]])!]
                ])!
            ])
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    let range = {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
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
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:1"
    let doc1 = """
      root
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
      """
    let range2 = "[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:1..<[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:3"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// regression test for incorrect use of `isForked(...)`
  @Test
  func regress_isForked() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(
          level: 1,
          [
            TextNode("Alpha "),
            EquationNode(
              isBlock: false,
              nucleus: [
                FractionNode(numerator: [TextNode("m+n")], denominator: [TextNode("n")]),
                TextNode("-c>100"),
              ]
            ),
          ])
      ])
      return self.createDocumentManager(rootNode)
    }()
    let range = {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      return RhTextRange(TextLocation(path, 0), TextLocation(path, 1))!
    }()
    let range1 = "[0↓,1↓,nucleus,0↓]:0"
    let doc1 = """
      root
      └ heading
        ├ text "Alpha "
        └ equation
          └ nucleus
            └ text "-c>100"
      """
    let range2 = "[0↓,1↓,nucleus]:0..<[0↓,1↓,nucleus,1↓]:0"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// regression test for start paragraph is empty
  @Test
  func regress_startParagraphIsEmpty() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode(),
        ParagraphNode([
          TextNode("The quick brown fox jumps over the lazy dog.")
        ]),
      ])
      return createDocumentManager(rootNode)
    }()
    let range = {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let location = TextLocation(path, 0)
      let endPath: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let endLocation = TextLocation(endPath, "T".count)
      return RhTextRange(location, endLocation)!
    }()
    let range1 = "[0↓,0↓]:0"
    let doc1 = """
      root
      └ paragraph
        └ text "he quick brown fox jumps over the lazy dog."
      """
    let range2 = "[0↓]:0..<[1↓,0↓]:1"
    self.testRoundTrip(
      range, nil, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// regression test for cross-paragraph deletion
  @Test
  func regress_crossParagraph() throws {
    // reset counter to ensure consistent node identifiers
    NodeIdAllocator.resetCounter()

    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([TextNode("Book I ")]),
        ParagraphNode([
          TextNode("The quick brown fox jumps over the lazy dog.")
        ]),
      ])
      return createDocumentManager(rootNode)
    }()

    let original = documentManager.prettyPrint()

    let expected0 = try Regex(
      """
      root
      snapshot: nil
      ├ \\([0-9]+\\) paragraph
      │ snapshot: nil
      │ └ \\([0-9]+\\) text "Book I "
      └ \\([0-9]+\\) paragraph
        snapshot: nil
        └ \\([0-9]+\\) text "The quick brown fox jumps over the lazy dog\\."
      """)
    #expect(try expected0.wholeMatch(in: documentManager.debugPrint()) != nil)

    let range = {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, "Book ".count)
      let endPath: [RohanIndex] = [
        .index(1),  // paragraph
        .index(0),  // text
      ]
      let endLocation = TextLocation(endPath, "T".count)
      return RhTextRange(location, endLocation)!
    }()
    let (range1, deleted1) =
      DMUtils.replaceContents(in: range, with: nil, documentManager)
    #expect("\(range1)" == "[0↓,0↓]:5")

    let expected1 = try Regex(
      """
      root
      snapshot: \\(\\d+,8\\+1\\), \\(\\d+,45\\+0\\)
      └ \\(\\d+\\) paragraph
        snapshot: \\(\\d+,7\\+0\\)
        └ \\(\\d+\\) text "Book he quick brown fox jumps over the lazy dog\\."
      """)
    #expect(try expected1.wholeMatch(in: documentManager.debugPrint()) != nil)

    // revert
    let (range2, _) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓,0↓]:5..<[1↓,0↓]:1")
    #expect(documentManager.prettyPrint() == original)
  }
}
