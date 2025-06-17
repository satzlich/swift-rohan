// Copyright 2024-2025 Lie Yan

import Algorithms
import AppKit
import Foundation
import Testing
import _RopeModule

@testable import SwiftRohan

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
          StrongNode(.emph, [TextNode(" lazy")]),
          TextNode(" dog."),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    do {
      let documentManager = createDocumentManager()

      // paragraph -> text -> <offset>
      let location = TextLocation.compose("[↓0,↓0]", "The quick brown fox jumps".length)!
      // paragraph -> text -> <offset>
      let endLocation = TextLocation.compose("[↓0,↓2]", " dog".length)!

      let textRange = RhTextRange(location, endLocation)!
      let range1 = "[↓0,↓0]:25..<[↓0,↓0]:31"
      let string: BigString = " gaily"
      let doc1 = """
        root
        └ paragraph
          └ text "The quick brown fox jumps gaily."
        """
      let range2 = "[↓0,↓0]:25..<[↓0,↓2]:4"
      self.testRoundTrip(
        textRange, string, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // opaque
    do {
      let documentManager = createDocumentManager()

      // paragraph -> emphasis -> text -> <offset>
      let location = TextLocation.compose("[↓0,↓1,↓0]", 0)!
      // paragraph -> emphasis -> text -> <offset>
      let endLocation = TextLocation.compose("[↓0,↓1,↓0]", " lazy".length)!

      let textRange = RhTextRange(location, endLocation)!
      let range1 = "[↓0,↓1]:0"
      let doc1 = """
        root
        └ paragraph
          ├ text "The quick brown fox jumps over the"
          ├ textStyles(emph)
          └ text " dog."
        """
      let range2 = "[↓0,↓1,↓0]:0..<[↓0,↓1,↓0]:5"
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
            StrongNode(.emph, [TextNode(" Second")]),
            TextNode(" Law of Motion"),
          ])
      ])
      return self.createDocumentManager(rootNode)
    }

    // text node
    do {
      let documentManager = createDocumentManager()

      // heading -> emphasis -> text -> <offset>
      let location = TextLocation.compose("[↓0,↓1,↓0]", " ".length)!
      // heading -> emphasis -> text -> <offset>
      let endLocation = TextLocation.compose("[↓0,↓1,↓0]", " Second".length)!

      let textRange = RhTextRange(location, endLocation)!
      let range1 = "[↓0,↓1,↓0]:1..<[↓0,↓1,↓0]:4"
      let doc1 = """
        root
        └ heading
          ├ text "Newton's"
          ├ textStyles(emph)
          │ └ text " 2nd"
          └ text " Law of Motion"
        """
      let range2 = "[↓0,↓1,↓0]:1..<[↓0,↓1,↓0]:7"
      self.testRoundTrip(
        textRange, "2nd", documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // element node
    do {
      let documentManager = createDocumentManager()

      // heading -> <offset>
      let location = TextLocation.compose("[↓0]", 1)!
      // heading -> <offset>
      let endLocation = TextLocation.compose("[↓0]", 2)!

      let textRange = RhTextRange(location, endLocation)!
      let string: BigString = " Second"
      let range1 = "[↓0,↓0]:8..<[↓0,↓0]:15"
      let doc1 = """
        root
        └ heading
          └ text "Newton's Second Law of Motion"
        """
      let range2 = "[↓0,↓0]:8..<[↓0,↓2]:0"
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
            StrongNode(.emph, [TextNode(" Second")]),
            TextNode(" Law of Motion"),
          ]),
        ParagraphNode([
          TextNode("The law states:"),
          EquationNode(
            .block,
            [
              TextNode("F=m"),
              FractionNode(num: [TextNode("dv")], denom: [TextNode("dt")]),
              TextNode("."),
            ]),
        ]),
      ])
      return self.createDocumentManager(rootNode)
    }

    // (text, text)
    do {
      let documentManager = createDocumentManager()

      // heading -> text -> <offset>
      let location = TextLocation.compose("[↓0,↓0]", "N".length)!
      // heading -> text -> <offset>
      let endLocation = TextLocation.compose("[↓0,↓2]", " Law of M".length)!

      let textRange = RhTextRange(location, endLocation)!
      let range1 = "[↓0,↓0]:1"
      let doc1 = """
        root
        ├ heading
        │ └ text "Notion"
        └ paragraph
          ├ text "The law states:"
          └ equation
            └ nuc
              ├ text "F=m"
              ├ fraction
              │ ├ num
              │ │ └ text "dv"
              │ └ denom
              │   └ text "dt"
              └ text "."
        """
      let range2 = "[↓0,↓0]:1..<[↓0,↓2]:9"
      self.testRoundTrip(
        textRange, nil, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // (text, element)
    do {
      let documentManager = createDocumentManager()

      // heading -> text -> <offset>
      let location = TextLocation.compose("[↓0,↓0]", "Newton".length)!
      // heading -> <offset>
      let endLocation = TextLocation.compose("[↓0]", 3)!

      let textRange = RhTextRange(location, endLocation)!
      let range1 = "[↓0,↓0]:6"
      let doc1 = """
        root
        ├ heading
        │ └ text "Newton"
        └ paragraph
          ├ text "The law states:"
          └ equation
            └ nuc
              ├ text "F=m"
              ├ fraction
              │ ├ num
              │ │ └ text "dv"
              │ └ denom
              │   └ text "dt"
              └ text "."
        """
      let range2 = "[↓0,↓0]:6..<[↓0,↓2]:14"
      self.testRoundTrip(
        textRange, nil, documentManager, range1: range1, doc1: doc1, range2: range2)
    }
    // (element, text)
    do {
      let documentManager = createDocumentManager()

      // heading -> <offset>
      let location = TextLocation.compose("[↓0]", 0)!
      // heading -> text -> <offset>
      let endLocation = TextLocation.compose("[↓0,↓2]", " Law of ".length)!

      let textRange = RhTextRange(location, endLocation)!
      let range1 = "[↓0,↓0]:0"
      let doc1 = """
        root
        ├ heading
        │ └ text "Motion"
        └ paragraph
          ├ text "The law states:"
          └ equation
            └ nuc
              ├ text "F=m"
              ├ fraction
              │ ├ num
              │ │ └ text "dv"
              │ └ denom
              │   └ text "dt"
              └ text "."
        """
      let range2 = "[↓0,↓0]:0..<[↓0,↓2]:8"
      self.testRoundTrip(
        textRange, nil, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // (element, text)
    do {
      let documentManager = createDocumentManager()

      // <offset>
      let location = TextLocation.compose("[]", 0)!
      // paragraph -> text -> <offset>
      let endLocation = TextLocation.compose("[↓1,↓0]", "The law states:".length)!

      let textRange = RhTextRange(location, endLocation)!
      let range1 = "[↓0]:0"
      let doc1 = """
        root
        └ paragraph
          └ equation
            └ nuc
              ├ text "F=m"
              ├ fraction
              │ ├ num
              │ │ └ text "dv"
              │ └ denom
              │   └ text "dt"
              └ text "."
        """
      let range2 = "[]:0..<[↓1,↓0]:15"
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
          StrongNode(.emph, [TextNode("brown ")]),
          TextNode("fox jumps over "),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // paragraph -> text -> <offset>
    let location = TextLocation.compose("[↓0,↓0]", 0)!
    // paragraph -> <offset>
    let endLocation = TextLocation.compose("[↓0]", 2)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0,↓0]:0"
    let doc1 = """
      root
      └ paragraph
        └ text "fox jumps over "
      """
    let range2 = "[↓0,↓0]:0..<[↓0,↓2]:0"
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
          StrongNode(.emph, [TextNode("brown ")]),
          TextNode("fox jumps over "),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // paragraph -> text -> <offset>
    let location = TextLocation.compose("[↓0,↓0]", 0)!
    // <offset>
    let endLocation = TextLocation.compose("[]", 1)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[]:0"
    let doc1 = """
      root
      """
    let range2 = "[↓0,↓0]:0..<[]:1"
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
          StrongNode(.emph, [TextNode("brown ")]),
          TextNode("fox jumps over "),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // paragraph -> <offset>
    let location = TextLocation.compose("[↓0]", 1)!
    // paragraph -> text -> <offset>
    let endLocation = TextLocation.compose("[↓0,↓2]", "fox ".length)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0,↓0]:10"
    let doc1 = """
      root
      └ paragraph
        └ text "the quick jumps over "
      """
    let range2 = "[↓0,↓0]:10..<[↓0,↓2]:4"
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

    // paragraph -> text
    let path: Array<RohanIndex> = TextLocation.parseIndices("[↓1,↓0]")!
    // paragraph -> text
    let endPath: Array<RohanIndex> = TextLocation.parseIndices("[↓3,↓0]")!

    let text = "Mary has a little lamb."
    let endText = "Veni. Vedi. Veci."

    let offsets = [0, "Mary".length, text.length]
    let endOffsets = [0, "Veni.".length, endText.length]
    let indices = product(offsets.indices, endOffsets.indices)

    typealias ExpectedResult = (range1: String, doc1: String, range2: String)

    let results: Array<ExpectedResult> = [
      // i = 0
      (
        "[↓1,↓0]:0",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Veni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:0..<[↓3,↓0]:0"
      ),
      (
        "[↓1,↓0]:0",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text " Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:0..<[↓3,↓0]:5"
      ),
      (
        "[↓1]:0",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:0..<[↓3,↓0]:17"
      ),
      // i = 1
      (
        "[↓1,↓0]:4",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "MaryVeni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:4..<[↓3,↓0]:0"
      ),
      (
        "[↓1,↓0]:4",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:4..<[↓3,↓0]:5"
      ),
      (
        "[↓1,↓0]:4",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary"
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:4..<[↓3,↓0]:17"
      ),
      // i = 2
      (
        "[↓1,↓0]:23",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb.Veni. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:23..<[↓3,↓0]:0"
      ),
      (
        "[↓1,↓0]:23",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb. Vedi. Veci."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:23..<[↓3,↓0]:5"
      ),
      (
        "[↓1,↓0]:23",
        """
        root
        ├ heading
        │ └ text "Hello Wolrd"
        ├ paragraph
        │ └ text "Mary has a little lamb."
        └ paragraph
          └ text "All I want is freedom. A world with no more night."
        """,
        "[↓1,↓0]:23..<[↓3,↓0]:17"
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
          StrongNode(.emph, [TextNode("the quick ")]),
          TextNode("brown fox "),
          StrongNode(.emph, [TextNode("jumps over ")]),
          TextNode("the lazy "),
          StrongNode(.emph, [TextNode("dog.")]),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // paragraph -> text -> <offset>
    let location = TextLocation.compose("[↓0,↓1]", 0)!
    // paragraph -> text -> <offset>
    let endLocation = TextLocation.compose("[↓0,↓3]", "the lazy ".length)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0]:1"
    let doc1 = """
      root
      └ paragraph
        ├ textStyles(emph)
        │ └ text "the quick "
        └ textStyles(emph)
          └ text "dog."
      """
    let range2 = "[↓0,↓1]:0..<[↓0,↓3]:9"
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
          StrongNode(.emph, [TextNode("fox ")]),
        ]),
        ParagraphNode([
          TextNode("jumps over the lazy dog.")  // text_2
        ]),
      ])
      return self.createDocumentManager(rootNode)
    }()

    // paragraph -> <offset>
    let location = TextLocation.compose("[↓0]", 1)!
    // paragraph -> text -> <offset>
    let endLocation = TextLocation.compose("[↓1,↓0]", "jumps over the lazy ".length)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0,↓0]:16"
    let doc1 = """
      root
      └ paragraph
        └ text "the quick brown dog."
      """
    let range2 = "[↓0,↓0]:16..<[↓1,↓0]:20"
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
            MathTemplateSamples.doubleText,
            [
              [ApplyNode(MathTemplateSamples.doubleText, [[TextNode("foxpro")]])!]
            ])!,
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // paragraph -> apply -> #0 -> apply -> #0 -> text -> <offset>
    let location = TextLocation.compose("[↓0,↓1,⇒0,↓0,⇒0,↓0]", "fox".length)!
    let endLocation = TextLocation.compose("[↓0,↓1,⇒0,↓0,⇒0,↓0]", "foxpro".length)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0,↓1,⇒0,↓0,⇒0,↓0]:3"
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
            │     ├ textStyles(emph)
            │     │ └ variable #0
            │     │   └ text "fox"
            │     └ text "}"
            ├ text " and "
            ├ textStyles(emph)
            │ └ variable #0
            │   └ template(doubleText)
            │     ├ argument #0 (x2)
            │     └ content
            │       ├ text "{"
            │       ├ variable #0
            │       │ └ text "fox"
            │       ├ text " and "
            │       ├ textStyles(emph)
            │       │ └ variable #0
            │       │   └ text "fox"
            │       └ text "}"
            └ text "}"
      """
    let range2 = "[↓0,↓1,⇒0,↓0,⇒0,↓0]:3..<[↓0,↓1,⇒0,↓0,⇒0,↓0]:6"
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
              .inline,
              [
                TextNode("m+"),
                ApplyNode(
                  MathTemplateSamples.complexFraction,
                  [[TextNode("x")], [TextNode("1+y")]])!,
                TextNode("+n"),
              ])
          ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // heading -> equation -> nucleus -> apply -> #1 -> text
    let location = TextLocation.compose("[↓0,↓0,nuc,↓1,⇒1,↓0]", 0)!
    let endLocation = TextLocation.compose("[↓0,↓0,nuc,↓1,⇒1,↓0]", "1+".length)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0,↓0,nuc,↓1,⇒1,↓0]:0"
    let doc1 = """
      root
      └ heading
        └ equation
          └ nuc
            ├ text "m+"
            ├ template(complexFraction)
            │ ├ argument #0 (x2)
            │ ├ argument #1 (x2)
            │ └ content
            │   └ fraction
            │     ├ num
            │     │ └ fraction
            │     │   ├ num
            │     │   │ ├ variable #1
            │     │   │ │ └ text "y"
            │     │   │ └ text "+1"
            │     │   └ denom
            │     │     ├ variable #0
            │     │     │ └ text "x"
            │     │     └ text "+1"
            │     └ denom
            │       ├ variable #0
            │       │ └ text "x"
            │       ├ text "+"
            │       ├ variable #1
            │       │ └ text "y"
            │       └ text "+1"
            └ text "+n"
      """
    let range2 = "[↓0,↓0,nuc,↓1,⇒1,↓0]:0..<[↓0,↓0,nuc,↓1,⇒1,↓0]:2"
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
            .block,
            [
              ApplyNode(
                MathTemplateSamples.bifun,
                [
                  [ApplyNode(MathTemplateSamples.bifun, [[TextNode("n-k+1")]])!]
                ])!
            ])
        ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // paragraph -> equation -> nucleus -> apply -> #0 -> apply -> #0 -> text
    let location = TextLocation.compose("[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]", "n".length)!
    let endLocation = TextLocation.compose("[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]", "n-k".length)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:1"
    let doc1 = """
      root
      └ paragraph
        └ equation
          └ nuc
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
    let range2 = "[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:1..<[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:3"
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
              .inline,
              [
                FractionNode(num: [TextNode("m+n")], denom: [TextNode("n")]),
                TextNode("-c>100"),
              ]
            ),
          ])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // heading -> equation -> nucleus -> <offset>
    let location = TextLocation.compose("[↓0,↓1,nuc]", 0)!
    let endLocation = TextLocation.compose("[↓0,↓1,nuc]", 1)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0,↓1,nuc,↓0]:0"
    let doc1 = """
      root
      └ heading
        ├ text "Alpha "
        └ equation
          └ nuc
            └ text "-c>100"
      """
    let range2 = "[↓0,↓1,nuc]:0..<[↓0,↓1,nuc,↓1]:0"
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

    // paragraph -> <offset>
    let location = TextLocation.compose("[↓0]", 0)!
    // paragraph -> text -> <offset>
    let endLocation = TextLocation.compose("[↓1,↓0]", "T".length)!

    let range = RhTextRange(location, endLocation)!
    let range1 = "[↓0,↓0]:0"
    let doc1 = """
      root
      └ paragraph
        └ text "he quick brown fox jumps over the lazy dog."
      """
    let range2 = "[↓0]:0..<[↓1,↓0]:1"
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

    // paragraph -> text -> <offset>
    let location = TextLocation.compose("[↓0,↓0]", "Book ".length)!
    // paragraph -> text -> <offset>
    let endLocation = TextLocation.compose("[↓1,↓0]", "T".length)!

    let range = RhTextRange(location, endLocation)!
    let (range1, deleted1) =
      TextKitTestsBase.copyReplaceContents(in: range, with: nil, documentManager)
    #expect("\(range1)" == "[↓0,↓0]:5")

    // revert
    let (range2, _) =
      TextKitTestsBase.copyReplaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[↓0,↓0]:5..<[↓1,↓0]:1")
    #expect(documentManager.prettyPrint() == original)
  }
}
