// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class InsertInlineContentTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  /// Insert inline content into a location inside a text node.
  @Test
  func test_insertInlineContent_textNode_beginning() throws {
    let documentManager = {
      let rootNode = RootNode([HeadingNode(.sectionAst, [TextNode("fox the ")])])
      return createDocumentManager(rootNode)
    }()

    // heading -> text -> <offset>
    let range = RhTextRange.parse("[↓0,↓0]:0")!

    let content = [
      TextNode("the "),
      TextStylesNode(.emph, [TextNode("quick brown ")]),
    ]
    let range1 = "[↓0,↓0]:0..<[↓0,↓2]:0"
    let doc1 = """
      root
      └ heading
        ├ text "the "
        ├ emph
        │ └ text "quick brown "
        └ text "fox the "
      """
    let range2 = "[↓0,↓0]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertInlineContent_textNode_end() throws {
    let documentManager = {
      let rootNode = RootNode([HeadingNode(.sectionAst, [TextNode("fox the ")])])
      return createDocumentManager(rootNode)
    }()

    // insert

    // heading -> text -> <offset>
    let offset = "fox the ".length
    let range = RhTextRange.parse("[↓0,↓0]:\(offset)")!
    let content = [
      TextStylesNode(.emph, [TextNode("lazy ")]),
      TextNode("dog"),
    ]

    let range1 = "[↓0,↓0]:8..<[↓0,↓2]:3"
    let doc1 = """
      root
      └ heading
        ├ text "fox the "
        ├ emph
        │ └ text "lazy "
        └ text "dog"
      """
    let range2 = "[↓0,↓0]:8"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertInlineContent_textNode_mid() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([HeadingNode(.sectionAst, [TextNode("fox the ")])])
      return self.createDocumentManager(rootNode)
    }

    let offset = "fox ".length
    // heading -> text -> <offset>
    let range = RhTextRange.parse("[↓0,↓0]:\(offset)")!

    // insert into middle of text node

    // (non-text, non-text)
    do {
      let content = [
        TextStylesNode(.emph, [TextNode("jumps ")]),
        TextNode("gaily "),
        TextStylesNode(.emph, [TextNode("over ")]),
      ]
      let documentManager = createDocumentManager()

      let range1 = "[↓0,↓0]:4..<[↓0,↓4]:0"
      let doc1 = """
        root
        └ heading
          ├ text "fox "
          ├ emph
          │ └ text "jumps "
          ├ text "gaily "
          ├ emph
          │ └ text "over "
          └ text "the "
        """
      let range2 = "[↓0,↓0]:4"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // (text, non-text)
    do {
      let content = [
        TextNode("jumps "),
        TextStylesNode(.emph, [TextNode("over ")]),
      ]
      let documentManager = createDocumentManager()
      let range1 = "[↓0,↓0]:4..<[↓0,↓2]:0"
      let doc1 = """
        root
        └ heading
          ├ text "fox jumps "
          ├ emph
          │ └ text "over "
          └ text "the "
        """
      let range2 = "[↓0,↓0]:4"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // (non-text, text)
    do {
      let content = [
        TextStylesNode(.emph, [TextNode("jumps ")]),
        TextNode("over "),
      ]
      let documentManager = createDocumentManager()
      let range1 = "[↓0,↓0]:4..<[↓0,↓2]:5"
      let doc1 = """
        root
        └ heading
          ├ text "fox "
          ├ emph
          │ └ text "jumps "
          └ text "over the "
        """
      let range2 = "[↓0,↓0]:4"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // (text, text)
    do {
      let content = [
        TextNode("jumps "),
        TextStylesNode(.emph, [TextNode("gaily ")]),
        TextNode("over "),
      ]
      let documentManager = createDocumentManager()
      let range1 = "[↓0,↓0]:4..<[↓0,↓2]:5"
      let doc1 = """
        root
        └ heading
          ├ text "fox jumps "
          ├ emph
          │ └ text "gaily "
          └ text "over the "
        """
      let range2 = "[↓0,↓0]:4"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  /// Insert inline content into a location inside a paragraph container.
  @Test
  func test_insertInlineContent_paragraphContainer_empty() throws {
    let documentManager = {
      let rootNode = RootNode()
      return createDocumentManager(rootNode)
    }()

    let range = RhTextRange.parse("[]:0")!
    let content = [
      TextStylesNode(.emph, [TextNode("the quick brown ")]),
      TextNode("fox"),
    ]
    let range1 = "[↓0]:0..<[]:1"
    let doc1 = """
      root
      └ paragraph
        ├ emph
        │ └ text "the quick brown "
        └ text "fox"
      """
    let range2 = "[]:0"

    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// Insert inline content into a location inside a paragraph container.
  @Test
  func test_insertInlineContent_paragraphContainer_end() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([TextNode("the quick brown ")])
      ])
      return self.createDocumentManager(rootNode)
    }()

    let range = RhTextRange.parse("[]:1")!
    let content = [
      TextStylesNode(.emph, [TextNode("fox ")]),
      TextNode("jumps over the lazy dog"),
    ]
    let range1 = "[↓1]:0..<[]:2"
    let doc1 = """
      root
      ├ paragraph
      │ └ text "the quick brown "
      └ paragraph
        ├ emph
        │ └ text "fox "
        └ text "jumps over the lazy dog"
      """
    let range2 = "[]:1"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)

    // TODO: add test for the case where the last node is non-element
  }

  @Test
  func test_insertInlineContent_paragraphContainer_beginningOrMiddle() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([TextNode("fox over the lazy dog")])
      ])
      return self.createDocumentManager(rootNode)
    }()

    let range = RhTextRange.parse("[]:0")!
    let content = [
      TextNode("the "),
      TextStylesNode(.emph, [TextNode("quick brown ")]),
    ]

    let range1 = "[↓0,↓0]:0..<[↓0,↓2]:0"
    let doc1 = """
      root
      └ paragraph
        ├ text "the "
        ├ emph
        │ └ text "quick brown "
        └ text "fox over the lazy dog"
      """
    let range2 = "[↓0,↓0]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)

    // TODO: add test for the case where the node is non-element
  }

  /// Insert inline content into a location inside an element node.
  @Test
  func test_insertInlineContent_elementNode_empty() throws {
    let documentManager = {
      let rootNode = RootNode([HeadingNode(.sectionAst, [])])
      return self.createDocumentManager(rootNode)
    }()

    // heading -> <offset>
    let range = RhTextRange.parse("[↓0]:0")!

    let content = [
      TextStylesNode(.emph, [TextNode("the quick brown ")]),
      TextNode("fox"),
    ]

    let range1 = "[↓0]:0..<[↓0,↓1]:3"
    let doc1 = """
      root
      └ heading
        ├ emph
        │ └ text "the quick brown "
        └ text "fox"
      """
    let range2 = "[↓0]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// Insert inline content into a location inside an element node.
  @Test
  func test_insertInlineContent_elementNode_end() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        HeadingNode(.sectionAst, [TextNode("the quick brown ")])
      ])
      return self.createDocumentManager(rootNode)
    }

    // heading -> <offset>
    let range = RhTextRange.parse("[↓0]:1")!

    do {
      let documentManager = createDocumentManager()
      let content = [
        TextStylesNode(.emph, [TextNode("jumps over ")]),
        TextNode("the lazy dog"),
      ]

      let range1 = "[↓0,↓0]:16..<[↓0,↓2]:12"
      let doc1 = """
        root
        └ heading
          ├ text "the quick brown "
          ├ emph
          │ └ text "jumps over "
          └ text "the lazy dog"
        """
      let range2 = "[↓0,↓0]:16"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {
      let documentManager = createDocumentManager()
      let content = [
        TextNode("jumps over "),
        TextStylesNode(.emph, [TextNode("the lazy dog")]),
      ]

      let range1 = "[↓0,↓0]:16..<[↓0]:2"
      let doc1 = """
        root
        └ heading
          ├ text "the quick brown jumps over "
          └ emph
            └ text "the lazy dog"
        """
      let range2 = "[↓0,↓0]:16"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  @Test
  func test_insertInlineContent_elementNode_beginning() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(.sectionAst, [TextNode("jumps over the lazy dog")])
      ])
      return self.createDocumentManager(rootNode)
    }()

    // heading -> <offset>
    let range = RhTextRange.parse("[↓0]:0")!

    let content = [
      TextNode("the "),
      TextStylesNode(.emph, [TextNode("quick brown ")]),
      TextNode("fox "),
    ]

    let range1 = "[↓0,↓0]:0..<[↓0,↓2]:4"
    let doc1 = """
      root
      └ heading
        ├ text "the "
        ├ emph
        │ └ text "quick brown "
        └ text "fox jumps over the lazy dog"
      """
    let range2 = "[↓0,↓0]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// Insert inline content into a location inside an element node.
  @Test
  func test_insertInlineContent_elementNode_mid() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        HeadingNode(
          .sectionAst,
          [
            TextNode("quick brown "),
            TextStylesNode(.emph, [TextNode("over ")]),
            TextNode("dog"),
          ])
      ])
      let documentManager = self.createDocumentManager(rootNode)
      return documentManager
    }

    // (previous is text, first-to-insert is text)
    do {
      let documentManager = createDocumentManager()
      // heading -> <offset>
      let range = RhTextRange.parse("[↓0]:1")!
      let content = [
        TextNode("fox "),
        TextStylesNode(.emph, [TextNode("jumps ")]),
      ]

      let range1 = "[↓0,↓0]:12..<[↓0]:2"
      let doc1 = """
        root
        └ heading
          ├ text "quick brown fox "
          ├ emph
          │ └ text "jumps "
          ├ emph
          │ └ text "over "
          └ text "dog"
        """
      let range2 = "[↓0,↓0]:12"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // (last-to-insert is text, next is text)
    do {
      let documentManager = createDocumentManager()
      // heading -> <offset>
      let range = RhTextRange.parse("[↓0]:2")!
      let content = [
        TextStylesNode(.emph, [TextNode("the ")]),
        TextNode("lazy "),
      ]

      let range1 = "[↓0]:2..<[↓0,↓3]:5"
      let doc1 = """
        root
        └ heading
          ├ text "quick brown "
          ├ emph
          │ └ text "over "
          ├ emph
          │ └ text "the "
          └ text "lazy dog"
        """
      let range2 = "[↓0,↓2]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // otherwise
    do {
      let documentManager = createDocumentManager()
      // heading -> <offset>
      let range = RhTextRange.parse("[↓0]:2")!

      let content = [
        TextStylesNode(.emph, [TextNode("the lazy ")])
      ]

      let range1 = "[↓0]:2..<[↓0,↓3]:0"
      let doc1 = """
        root
        └ heading
          ├ text "quick brown "
          ├ emph
          │ └ text "over "
          ├ emph
          │ └ text "the lazy "
          └ text "dog"
        """
      let range2 = "[↓0,↓2]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  @Test
  func test_insertInlineContent_ApplyNode() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([
          EquationNode(
            .inline,
            [
              ApplyNode(
                MathTemplateSamples.bifun,
                [[ApplyNode(MathTemplateSamples.bifun, [[TextNode("m+1")]])!]])!
            ])
        ])
      ])
      return createDocumentManager(rootNode)
    }()

    // paragraph -> equation -> nucleus -> apply -> #0 -> apply -> #0 -> <offset>
    let range = RhTextRange.parse("[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0]:0")!

    let content = [
      FractionNode(num: [TextNode("m")], denom: [TextNode("n")]),
      TextNode("+"),
    ]

    let range1 = "[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0]:0..<[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓1]:1"

    let doc1 = """
      root
      └ paragraph
        └ equation
          └ nuc
            └ template(bifun)
              ├ argument #0 (x2)
              └ expansion
                ├ text "f("
                ├ variable #0
                │ └ template(bifun)
                │   ├ argument #0 (x2)
                │   └ expansion
                │     ├ text "f("
                │     ├ variable #0
                │     │ ├ fraction
                │     │ │ ├ num
                │     │ │ │ └ text "m"
                │     │ │ └ denom
                │     │ │   └ text "n"
                │     │ └ text "+m+1"
                │     ├ text ","
                │     ├ variable #0
                │     │ ├ fraction
                │     │ │ ├ num
                │     │ │ │ └ text "m"
                │     │ │ └ denom
                │     │ │   └ text "n"
                │     │ └ text "+m+1"
                │     └ text ")"
                ├ text ","
                ├ variable #0
                │ └ template(bifun)
                │   ├ argument #0 (x2)
                │   └ expansion
                │     ├ text "f("
                │     ├ variable #0
                │     │ ├ fraction
                │     │ │ ├ num
                │     │ │ │ └ text "m"
                │     │ │ └ denom
                │     │ │   └ text "n"
                │     │ └ text "+m+1"
                │     ├ text ","
                │     ├ variable #0
                │     │ ├ fraction
                │     │ │ ├ num
                │     │ │ │ └ text "m"
                │     │ │ └ denom
                │     │ │   └ text "n"
                │     │ └ text "+m+1"
                │     └ text ")"
                └ text ")"
      """
    let range2 = "[↓0,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }
}
