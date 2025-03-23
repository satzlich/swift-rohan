// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

final class InsertStringTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func testInsertString_EmptyRoot() throws {
    let rootNode = RootNode([])
    let documentManager = createDocumentManager(rootNode)

    let location = TextLocation([], 0)
    let range = RhTextRange(location)
    let result = documentManager.replaceCharacters(in: range, with: "Hello, World!")
    assert(result.isSuccess)
    let insertionRange = result.success()!
    #expect("\(insertionRange.location)" == "[0↓,0↓]:0")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
          └ text "Hello, World!"
        """)
  }

  @Test
  func testInsertString() throws {
    let rootNode = RootNode([
      HeadingNode(
        level: 1,
        [
          EmphasisNode([TextNode("Newton's😀")])
        ]),
      ParagraphNode([
        EquationNode(
          isBlock: true,
          nucleus: [
            TextNode("=m"),
            FractionNode(numerator: [TextNode("d")], denominator: [TextNode("dt")]),
          ])
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)

    // check document
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ heading
        │ └ emphasis
        │   └ text "Newton's😀"
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

    // do insertion in the middle of a text node
    do {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // emphasis
        .index(0),  // text "Newton's"
      ]
      let offset = "Newton's".count
      let range = RhTextRange(TextLocation(path, offset))
      let result = documentManager.replaceCharacters(
        in: range, with: " Second Law of Motion")
      assert(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,0↓,0↓]:8")
    }

    // check document
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ heading
        │ └ emphasis
        │   └ text "Newton's Second Law of Motion😀"
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

    // do insertion in the root
    do {
      let location = TextLocation([], 1)
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(in: range, with: "states:")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[1↓,0↓]:0")
    }
    do {
      let location = TextLocation([], 1)
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(
        in: range, with: "The law of motion ")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[1↓,0↓]:0")
    }
    do {
      let location = TextLocation([], 2)
      let range = RhTextRange(location)
      let result = documentManager.replaceCharacters(in: range, with: "Veni. Vidi. Vici.")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[1↓,2↓]:0")
    }
    // check document
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ heading
        │ └ emphasis
        │   └ text "Newton's Second Law of Motion😀"
        └ paragraph
          ├ text "The law of motion states:"
          ├ equation
          │ └ nucleus
          │   ├ text "=m"
          │   └ fraction
          │     ├ numerator
          │     │ └ text "d"
          │     └ denominator
          │       └ text "dt"
          └ text "Veni. Vidi. Vici."
        """)

    // do insertion in the equation
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      let range = RhTextRange(TextLocation(path, 0))
      let result = documentManager.replaceCharacters(in: range, with: "F")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[1↓,1↓,nucleus,0↓]:0")
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // fraction
        .mathIndex(.numerator),  // numerator
      ]
      let range = RhTextRange(TextLocation(path, 1))
      let result = documentManager.replaceCharacters(in: range, with: "v")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[1↓,1↓,nucleus,1↓,numerator,0↓]:1")
    }
    do {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      let range = RhTextRange(TextLocation(path, 2))
      let result = documentManager.replaceCharacters(in: range, with: ".")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[1↓,1↓,nucleus,2↓]:0")
    }

    // check document
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ heading
        │ └ emphasis
        │   └ text "Newton's Second Law of Motion😀"
        └ paragraph
          ├ text "The law of motion states:"
          ├ equation
          │ └ nucleus
          │   ├ text "F=m"
          │   ├ fraction
          │   │ ├ numerator
          │   │ │ └ text "dv"
          │   │ └ denominator
          │   │   └ text "dt"
          │   └ text "."
          └ text "Veni. Vidi. Vici."
        """)
  }

  @Test
  func testInsertString_ElementNode() throws {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("The "),
        EmphasisNode([TextNode("brown ")]),
        EquationNode(isBlock: false, nucleus: [TextNode("jumps ")]),
        TextNode("the lazy dog."),
      ])
    ])
    let documentManager = createDocumentManager(rootNode)

    do {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let range = RhTextRange(TextLocation(path, 3))
      let result = documentManager.replaceCharacters(in: range, with: "over ")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,3↓]:0")
    }

    do {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let range = RhTextRange(TextLocation(path, 2))
      let result = documentManager.replaceCharacters(in: range, with: "fox ")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,2↓]:0")
    }

    do {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let range = RhTextRange(TextLocation(path, 1))
      let result = documentManager.replaceCharacters(in: range, with: "quick ")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,0↓]:4")
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
        """)
  }

  @Test
  func testInsertString_ApplyNode() throws {
    let rootNode = RootNode([
      ParagraphNode([
        TextNode("Sample of nested apply nodes: "),
        ApplyNode(
          CompiledSamples.doubleText,
          [
            [ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]
          ])!,
      ]),
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
        ]),
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
      let range = RhTextRange(TextLocation(path, offset))
      let result = documentManager.replaceCharacters(in: range, with: "pro")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[0↓,1↓,0⇒,0↓,0⇒,0↓]:3")
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
      let range = RhTextRange(TextLocation(path, 0))
      let result = documentManager.replaceCharacters(in: range, with: "1+")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[1↓,0↓,nucleus,1↓,1⇒,0↓]:0")
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
      let range = RhTextRange(TextLocation(path, offset))
      let result = documentManager.replaceCharacters(in: range, with: "-k")
      #expect(result.isSuccess)
      let insertionRange = result.success()!
      #expect("\(insertionRange.location)" == "[2↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:1")
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
        │     │     │ └ text "foxpro"
        │     │     ├ text " and "
        │     │     ├ emphasis
        │     │     │ └ variable #0
        │     │     │   └ text "foxpro"
        │     │     └ text "}"
        │     ├ text " and "
        │     ├ emphasis
        │     │ └ variable #0
        │     │   └ template(doubleText)
        │     │     ├ argument #0 (x2)
        │     │     └ content
        │     │       ├ text "{"
        │     │       ├ variable #0
        │     │       │ └ text "foxpro"
        │     │       ├ text " and "
        │     │       ├ emphasis
        │     │       │ └ variable #0
        │     │       │   └ text "foxpro"
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
        │     │     │   │ │ └ text "1+y"
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
        │     │       │ └ text "1+y"
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
  }
}
