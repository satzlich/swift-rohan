// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing
import _RopeModule

@testable import Rohan

final class InsertStringTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func test_insertString_emptyRoot() throws {
    let documentManager = {
      let rootNode = RootNode([])
      return createDocumentManager(rootNode)
    }()
    // insert
    let range = RhTextRange(TextLocation([], 0))
    let string: BigString = "Hello, World!"
    let (range1, deleted1) =
      DMUtils.replaceCharacters(in: range, with: string, documentManager)
    #expect("\(range1)" == "[0↓,0↓]:0..<[0↓,0↓]:13")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
          └ text "Hello, World!"
        """)

    // revert
    let (range2, deleted2) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓]:0")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
        """)
  }

  @Test
  func test_insertString_TextNode() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(level: 1, [EmphasisNode([TextNode("Newton's😀")])])
      ])
      return createDocumentManager(rootNode)
    }()

    // insert in the middle of a text node
    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // emphasis
        .index(0),  // text
      ]
      let offset = "Newton's".count
      return RhTextRange(TextLocation(indices, offset))
    }()
    let string: BigString = " Second Law of Motion"

    let (range1, deleted1) =
      DMUtils.replaceCharacters(in: range, with: string, documentManager)
    #expect("\(range1)" == "[0↓,0↓,0↓]:8..<[0↓,0↓,0↓]:29")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ heading
          └ emphasis
            └ text "Newton's Second Law of Motion😀"
        """)

    // revert
    let (range2, deleted2) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓,0↓,0↓]:8")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ heading
          └ emphasis
            └ text "Newton's😀"
        """)
  }

  @Test
  func test_insertString_RootNode() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(level: 1, []),
        ParagraphNode([EmphasisNode([TextNode("over ")])]),
      ])
      return createDocumentManager(rootNode)
    }()

    var rangeStack: [(InsertionRange, [Node])] = []
    // insert
    do {
      let range = RhTextRange(TextLocation([], 1))
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: "fox ", documentManager)
      rangeStack.append((range1, deleted1))
      #expect("\(range1)" == "[1↓,0↓]:0..<[1↓,0↓]:4")
    }
    do {
      let range = RhTextRange(TextLocation([], 1))
      let string: BigString = "The quick brown "
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: string, documentManager)
      rangeStack.append((range1, deleted1))
      #expect("\(range1)" == "[1↓,0↓]:0..<[1↓,0↓]:16")
    }
    do {
      let range = RhTextRange(TextLocation([], 2))
      let string: BigString = "the lazy dog."
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: string, documentManager)
      rangeStack.append((range1, deleted1))
      #expect("\(range1)" == "[1↓,2↓]:0..<[1↓,2↓]:13")
    }
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ heading
        └ paragraph
          ├ text "The quick brown fox "
          ├ emphasis
          │ └ text "over "
          └ text "the lazy dog."
        """)

    // revert
    var range2: InsertionRange? = nil
    for (range, deleted) in rangeStack.reversed() {
      let (insertionRange, _) =
        DMUtils.replaceContents(in: range, with: deleted, documentManager)
      range2 = insertionRange
    }
    #expect("\(range2!)" == "[1↓]:0")
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ heading
        └ paragraph
          └ emphasis
            └ text "over "
        """)
  }

  @Test
  func test_insertString_EquationNode() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EquationNode(
            isBlock: true,
            nucleus: [
              TextNode("=m"),
              FractionNode(numerator: [TextNode("d")], denominator: [TextNode("dt")]),
            ])
        ])
      ])
      return createDocumentManager(rootNode)
    }()

    var rangeStack: [(InsertionRange, [Node])] = []
    do {
      let range = {
        let indices: [RohanIndex] = [
          .index(0),  // paragraph
          .index(0),  // equation
          .mathIndex(.nucleus),  // nucleus
        ]
        return RhTextRange(TextLocation(indices, 0))
      }()
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: "F", documentManager)
      rangeStack.append((range1, deleted1))
      #expect("\(range1)" == "[0↓,0↓,nucleus,0↓]:0..<[0↓,0↓,nucleus,0↓]:1")
    }
    do {
      let range = {
        let indices: [RohanIndex] = [
          .index(0),  // paragraph
          .index(0),  // equation
          .mathIndex(.nucleus),  // nucleus
          .index(1),  // fraction
          .mathIndex(.numerator),  // numerator
        ]
        return RhTextRange(TextLocation(indices, 1))
      }()
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: "v", documentManager)
      rangeStack.append((range1, deleted1))
      #expect(
        "\(range1)"
          == "[0↓,0↓,nucleus,1↓,numerator,0↓]:1..<[0↓,0↓,nucleus,1↓,numerator,0↓]:2")
    }
    do {
      let range = {
        let indices: [RohanIndex] = [
          .index(0),  // paragraph
          .index(0),  // equation
          .mathIndex(.nucleus),  // nucleus
        ]
        return RhTextRange(TextLocation(indices, 2))
      }()
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: ".", documentManager)
      rangeStack.append((range1, deleted1))
      #expect("\(range1)" == "[0↓,0↓,nucleus,2↓]:0..<[0↓,0↓,nucleus,2↓]:1")
    }
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

    // revert
    var range2: InsertionRange? = nil
    for (range, deleted) in rangeStack.reversed() {
      let (insertionRange, _) =
        DMUtils.replaceContents(in: range, with: deleted, documentManager)
      range2 = insertionRange
    }
    #expect("\(range2!)" == "[0↓,0↓,nucleus,0↓]:0")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
          └ equation
            └ nucleus
              ├ text "=m"
              └ fraction
                ├ numerator
                │ └ text "d"
                └ denominator
                  └ text "dt"
        """)
  }

  @Test
  func test_insertString_ElementNode() {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("The "),
          EmphasisNode([TextNode("brown ")]),
          EquationNode(isBlock: false, nucleus: [TextNode("jumps ")]),
          TextNode("the lazy dog."),
        ])
      ])
      return createDocumentManager(rootNode)
    }()

    // insert
    func locationInParagraph(_ index: Int) -> RhTextRange {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      return RhTextRange(TextLocation(path, index))
    }

    var rangeStack: [(InsertionRange, [Node])] = []

    do {
      let range = locationInParagraph(3)
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: "over ", documentManager)
      rangeStack.append((range1, deleted1))
      #expect("\(range1)" == "[0↓,3↓]:0..<[0↓,3↓]:5")
    }
    do {
      let range = locationInParagraph(2)
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: "fox ", documentManager)
      rangeStack.append((range1, deleted1))
      #expect("\(range1)" == "[0↓,2↓]:0..<[0↓,2↓]:4")
    }
    do {
      let range = locationInParagraph(1)
      let (range1, deleted1) =
        DMUtils.replaceCharacters(in: range, with: "quick ", documentManager)
      rangeStack.append((range1, deleted1))
      #expect("\(range1)" == "[0↓,0↓]:4..<[0↓,0↓]:10")
    }
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
          ├ text "The quick "
          ├ emphasis
          │ └ text "brown "
          ├ text "fox "
          ├ equation
          │ └ nucleus
          │   └ text "jumps "
          └ text "over the lazy dog."
        """
    )

    // revert
    var range2: InsertionRange? = nil
    for (range, deleted) in rangeStack.reversed() {
      let (insertionRange, _) =
        DMUtils.replaceContents(in: range, with: deleted, documentManager)
      range2 = insertionRange
    }
    #expect("\(range2!)" == "[0↓,3↓]:0")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
          ├ text "The "
          ├ emphasis
          │ └ text "brown "
          ├ equation
          │ └ nucleus
          │   └ text "jumps "
          └ text "the lazy dog."
        """)
  }

  @Test
  func test_insertString_ApplyNode_doubleText() {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          ApplyNode(
            CompiledSamples.doubleText,
            [
              [ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]
            ])!
        ])
      ])
      return createDocumentManager(rootNode)
    }()

    // insert
    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // apply node
        .argumentIndex(0),  // first argument
        .index(0),  // nested apply node
        .argumentIndex(0),  // first argument
        .index(0),  // text
      ]
      let offset = "fox".count
      return RhTextRange(TextLocation(indices, offset))
    }()
    let (range1, deleted1) =
      DMUtils.replaceCharacters(in: range, with: "pro", documentManager)
    #expect("\(range1)" == "[0↓,0↓,0⇒,0↓,0⇒,0↓]:3..<[0↓,0↓,0⇒,0↓,0⇒,0↓]:6")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
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
              │     │ └ text "foxpro"
              │     ├ text " and "
              │     ├ emphasis
              │     │ └ variable #0
              │     │   └ text "foxpro"
              │     └ text "}"
              ├ text " and "
              ├ emphasis
              │ └ variable #0
              │   └ template(doubleText)
              │     ├ argument #0 (x2)
              │     └ content
              │       ├ text "{"
              │       ├ variable #0
              │       │ └ text "foxpro"
              │       ├ text " and "
              │       ├ emphasis
              │       │ └ variable #0
              │       │   └ text "foxpro"
              │       └ text "}"
              └ text "}"
        """)

    // revert
    let (range2, _) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓,0↓,0⇒,0↓,0⇒,0↓]:3")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
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
        """)
  }

  @Test
  func test_insertString_ApplyNode_complexFraction() {
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
                  CompiledSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])!,
                TextNode("+n"),
              ])
          ])
      ])
      return createDocumentManager(rootNode)
    }()

    // insert
    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // apply node
        .argumentIndex(1),  // second argument
        .index(0),  // text
      ]
      return RhTextRange(TextLocation(indices, 0))
    }()
    let (range1, deleted1) =
      DMUtils.replaceCharacters(in: range, with: "1+", documentManager)
    #expect("\(range1)" == "[0↓,0↓,nucleus,1↓,1⇒,0↓]:0..<[0↓,0↓,nucleus,1↓,1⇒,0↓]:2")
    #expect(
      documentManager.prettyPrint() == """
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
              │     │   │ │ └ text "1+y"
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
              │       │ └ text "1+y"
              │       └ text "+1"
              └ text "+n"
        """)

    // revert
    let (range2, _) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓,0↓,nucleus,1↓,1⇒,0↓]:0")
    #expect(
      documentManager.prettyPrint() == """
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
        """)
  }

  @Test
  func test_insertString_ApplyNode_bifun() {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EquationNode(
            isBlock: true,
            nucleus: [
              ApplyNode(
                CompiledSamples.bifun,
                [
                  [ApplyNode(CompiledSamples.bifun, [[TextNode("n+1")]])!]
                ])!
            ])
        ])
      ])
      return createDocumentManager(rootNode)
    }()

    // insert
    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // apply node
        .argumentIndex(0),  // first argument
        .index(0),  // apply node
        .argumentIndex(0),  // first argument
        .index(0),
      ]
      return RhTextRange(TextLocation(indices, "n".stringLength))
    }()
    let (range1, deleted1) =
      DMUtils.replaceCharacters(in: range, with: "-k", documentManager)
    #expect(
      "\(range1)" == "[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:1..<[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:3"
    )
    #expect(
      documentManager.prettyPrint() == """
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
                  │     │ └ text "n-k+1"
                  │     ├ text ","
                  │     ├ variable #0
                  │     │ └ text "n-k+1"
                  │     └ text ")"
                  ├ text ","
                  ├ variable #0
                  │ └ template(bifun)
                  │   ├ argument #0 (x2)
                  │   └ content
                  │     ├ text "f("
                  │     ├ variable #0
                  │     │ └ text "n-k+1"
                  │     ├ text ","
                  │     ├ variable #0
                  │     │ └ text "n-k+1"
                  │     └ text ")"
                  └ text ")"
        """)

    // revert
    let (range2, _) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:1")
    #expect(
      documentManager.prettyPrint() == """
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
        """)
  }
}
