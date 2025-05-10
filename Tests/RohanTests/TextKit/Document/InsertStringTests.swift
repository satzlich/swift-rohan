// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing
import _RopeModule

@testable import SwiftRohan

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
    let range1 = "[↓0,↓0]:0..<[]:1"
    let doc1 = """
      root
      └ paragraph
        └ text "Hello, World!"
      """
    let range2 = "[]:0"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
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
    let range1 = "[↓0,↓0,↓0]:8..<[↓0,↓0,↓0]:29"
    let doc1 = """
      root
      └ heading
        └ emphasis
          └ text "Newton's Second Law of Motion😀"
      """
    let range2 = "[↓0,↓0,↓0]:8"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertString_RootNode_1() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(level: 1, []),
        ParagraphNode([EmphasisNode([TextNode("over ")])]),
      ])
      return createDocumentManager(rootNode)
    }()
    let range = RhTextRange(TextLocation([], 1))
    let string: BigString = "fox "
    let range1 = "[↓1,↓0]:0..<[↓1,↓0]:4"
    let doc1 = """
      root
      ├ heading
      └ paragraph
        ├ text "fox "
        └ emphasis
          └ text "over "
      """
    let range2 = "[↓1]:0"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertString_RootNode_2() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(level: 1, []),
        ParagraphNode([
          TextNode("fox "),
          EmphasisNode([TextNode("over ")]),
        ]),
      ])
      return createDocumentManager(rootNode)
    }()
    let range = RhTextRange(TextLocation([], 1))
    let string: BigString = "the quick brown "
    let range1 = "[↓1,↓0]:0..<[↓1,↓0]:16"
    let doc1 = """
      root
      ├ heading
      └ paragraph
        ├ text "the quick brown fox "
        └ emphasis
          └ text "over "
      """
    let range2 = "[↓1,↓0]:0"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertString_RootNode_3() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(level: 1, []),
        ParagraphNode([
          TextNode("The quick brown fox "),
          EmphasisNode([TextNode("over ")]),
        ]),
      ])
      return createDocumentManager(rootNode)
    }()

    let range = RhTextRange(TextLocation([], 2))
    let string: BigString = "the lazy dog."

    let range1 = "[↓2,↓0]:0..<[]:3"
    let doc1 = """
      root
      ├ heading
      ├ paragraph
      │ ├ text "The quick brown fox "
      │ └ emphasis
      │   └ text "over "
      └ paragraph
        └ text "the lazy dog."
      """
    let range2 = "[]:2"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  // insert at an opaque top-level node
  @Test
  func test_insertString_RootNode_4() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([TextNode("hello world")]),
        HeadingNode(level: 1, [TextNode("Bonjour")]),
      ])
      return createDocumentManager(rootNode)
    }()
    let range = RhTextRange(TextLocation([], 1))
    let string: BigString = "Guten Tag"
    let range1 = "[↓1,↓0]:0..<[]:2"
    let doc1 = """
      root
      ├ paragraph
      │ └ text "hello world"
      ├ paragraph
      │ └ text "Guten Tag"
      └ heading
        └ text "Bonjour"
      """
    let range2 = "[]:1"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertString_EquationNode_1() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EquationNode(
            isBlock: true,
            nuc: [
              TextNode("=ma")
            ])
        ])
      ])
      return createDocumentManager(rootNode)
    }()
    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // equation
        .mathIndex(.nuc),  // nucleus
      ]
      return RhTextRange(TextLocation(indices, 0))
    }()
    let string: BigString = "F"
    let range1 = "[↓0,↓0,nuc,↓0]:0..<[↓0,↓0,nuc,↓0]:1"
    let doc1 = """
      root
      └ paragraph
        └ equation
          └ nuc
            └ text "F=ma"
      """
    let range2 = "[↓0,↓0,nuc,↓0]:0"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertString_EquationNode_2() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EquationNode(
            isBlock: true,
            nuc: [
              FractionNode(num: [TextNode("d")], denom: [TextNode("dt")])
            ])
        ])
      ])
      return createDocumentManager(rootNode)
    }()
    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // equation
        .mathIndex(.nuc),  // nucleus
        .index(0),  // fraction
        .mathIndex(.num),  // numerator
      ]
      return RhTextRange(TextLocation(indices, 1))
    }()
    let string: BigString = "v"
    let range1 = "[↓0,↓0,nuc,↓0,num,↓0]:1..<[↓0,↓0,nuc,↓0,num,↓0]:2"
    let doc1 = """
      root
      └ paragraph
        └ equation
          └ nuc
            └ fraction
              ├ num
              │ └ text "dv"
              └ denom
                └ text "dt"
      """
    let range2 = "[↓0,↓0,nuc,↓0,num,↓0]:1"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertString_EquationNode_3() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EquationNode(
            isBlock: true,
            nuc: [
              TextNode("F="),
              FractionNode(num: [TextNode("dv")], denom: [TextNode("dt")]),
            ])
        ])
      ])
      return createDocumentManager(rootNode)
    }()
    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // equation
        .mathIndex(.nuc),  // nucleus
      ]
      return RhTextRange(TextLocation(indices, 2))
    }()

    let string: BigString = "."
    let range1 = "[↓0,↓0,nuc,↓2]:0..<[↓0,↓0,nuc,↓2]:1"
    let doc1 = """
      root
      └ paragraph
        └ equation
          └ nuc
            ├ text "F="
            ├ fraction
            │ ├ num
            │ │ └ text "dv"
            │ └ denom
            │   └ text "dt"
            └ text "."
      """
    let range2 = "[↓0,↓0,nuc]:2"
    self.testRoundTrip(
      range, string, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertString_ElementNode() {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("The "),
          EmphasisNode([TextNode("brown ")]),
          EquationNode(isBlock: false, nuc: [TextNode("jumps ")]),
          TextNode("the lazy dog."),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    func range(for index: Int) -> RhTextRange {
      let path: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      return RhTextRange(TextLocation(path, index))
    }

    do {
      let documentManager = createDocumentManager()
      let range = range(for: 3)
      let string: BigString = "over "
      let range1 = "[↓0,↓3]:0..<[↓0,↓3]:5"
      let doc1 = """
        root
        └ paragraph
          ├ text "The "
          ├ emphasis
          │ └ text "brown "
          ├ equation
          │ └ nuc
          │   └ text "jumps "
          └ text "over the lazy dog."
        """
      let range2 = "[↓0,↓3]:0"
      self.testRoundTrip(
        range, string, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    do {
      let documentManager = createDocumentManager()
      let range = range(for: 2)
      let string: BigString = "fox "
      let range1 = "[↓0,↓2]:0..<[↓0,↓2]:4"
      let doc1 = """
        root
        └ paragraph
          ├ text "The "
          ├ emphasis
          │ └ text "brown "
          ├ text "fox "
          ├ equation
          │ └ nuc
          │   └ text "jumps "
          └ text "the lazy dog."
        """
      let range2 = "[↓0]:2"
      self.testRoundTrip(
        range, string, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {
      let documentManager = createDocumentManager()
      let range = range(for: 1)
      let string: BigString = "quick "
      let range1 = "[↓0,↓0]:4..<[↓0,↓0]:10"
      let doc1 = """
        root
        └ paragraph
          ├ text "The quick "
          ├ emphasis
          │ └ text "brown "
          ├ equation
          │ └ nuc
          │   └ text "jumps "
          └ text "the lazy dog."
        """
      let range2 = "[↓0,↓0]:4"
      self.testRoundTrip(
        range, string, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
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
    let range1 = "[↓0,↓0,⇒0,↓0,⇒0,↓0]:3..<[↓0,↓0,⇒0,↓0,⇒0,↓0]:6"
    let doc1 = """
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
      """
    let range2 = "[↓0,↓0,⇒0,↓0,⇒0,↓0]:3"
    self.testRoundTrip(
      range, "pro", documentManager,
      range1: range1, doc1: doc1, range2: range2)
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
              nuc: [
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
        .mathIndex(.nuc),  // nucleus
        .index(1),  // apply node
        .argumentIndex(1),  // second argument
        .index(0),  // text
      ]
      return RhTextRange(TextLocation(indices, 0))
    }()
    let range1 = "[↓0,↓0,nuc,↓1,⇒1,↓0]:0..<[↓0,↓0,nuc,↓1,⇒1,↓0]:2"
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
            │     │   │ │ └ text "1+y"
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
            │       │ └ text "1+y"
            │       └ text "+1"
            └ text "+n"
      """
    let range2 = "[↓0,↓0,nuc,↓1,⇒1,↓0]:0"
    self.testRoundTrip(
      range, "1+", documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertString_ApplyNode_bifun() {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EquationNode(
            isBlock: true,
            nuc: [
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
        .mathIndex(.nuc),  // nucleus
        .index(0),  // apply node
        .argumentIndex(0),  // first argument
        .index(0),  // apply node
        .argumentIndex(0),  // first argument
        .index(0),
      ]
      return RhTextRange(TextLocation(indices, "n".length))
    }()
    let range1 = "[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:1..<[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:3"
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
      """
    let range2 = "[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:1"
    self.testRoundTrip(
      range, "-k", documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }
}
