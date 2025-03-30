// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

final class InsertInlineContentTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  /// Insert inline content into a location inside a text node.
  @Test
  func test_insertInlineContent_textNode_beginning() throws {
    let documentManager = {
      let rootNode = RootNode([HeadingNode(level: 1, [TextNode("fox the ")])])
      return createDocumentManager(rootNode)
    }()

    // insert
    let range = {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      return RhTextRange(location)
    }()
    let content = [
      TextNode("the "),
      EmphasisNode([TextNode("quick brown ")]),
    ]
    let rang1 = "[0↓,0↓]:0..<[0↓,2↓]:0"
    let doc1 = """
      root
      └ heading
        ├ text "the "
        ├ emphasis
        │ └ text "quick brown "
        └ text "fox the "
      """
    let range2 = "[0↓,0↓]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: rang1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertInlineContent_textNode_end() throws {
    let documentManager = {
      let rootNode = RootNode([HeadingNode(level: 1, [TextNode("fox the ")])])
      return createDocumentManager(rootNode)
    }()

    // insert
    let range = {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // text
      ]
      let location = TextLocation(path, "fox the ".length)
      return RhTextRange(location)
    }()
    let content = [
      EmphasisNode([TextNode("lazy ")]),
      TextNode("dog"),
    ]

    let rang1 = "[0↓,0↓]:8..<[0↓,2↓]:3"
    let doc1 = """
      root
      └ heading
        ├ text "fox the "
        ├ emphasis
        │ └ text "lazy "
        └ text "dog"
      """
    let range2 = "[0↓,0↓]:8"
    self.testRoundTrip(
      range, content, documentManager,
      range1: rang1, doc1: doc1, range2: range2)
  }

  @Test
  func test_insertInlineContent_textNode_mid() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([HeadingNode(level: 1, [TextNode("fox the ")])])
      return self.createDocumentManager(rootNode)
    }
    let range = {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(0),  // text
      ]
      let location = TextLocation(path, "fox ".length)
      return RhTextRange(location)
    }()

    // insert into middle of text node

    // (non-text, non-text)
    do {
      let content = [
        EmphasisNode([TextNode("jumps ")]),
        TextNode("gaily "),
        EmphasisNode([TextNode("over ")]),
      ]
      let documentManager = createDocumentManager()

      let rang1 = "[0↓,0↓]:4..<[0↓,4↓]:0"
      let doc1 = """
        root
        └ heading
          ├ text "fox "
          ├ emphasis
          │ └ text "jumps "
          ├ text "gaily "
          ├ emphasis
          │ └ text "over "
          └ text "the "
        """
      let range2 = "[0↓,0↓]:4"
      self.testRoundTrip(
        range, content, documentManager,
        range1: rang1, doc1: doc1, range2: range2)
    }

    // (text, non-text)
    do {
      let content = [
        TextNode("jumps "),
        EmphasisNode([TextNode("over ")]),
      ]
      let documentManager = createDocumentManager()
      let rang1 = "[0↓,0↓]:4..<[0↓,2↓]:0"
      let doc1 = """
        root
        └ heading
          ├ text "fox jumps "
          ├ emphasis
          │ └ text "over "
          └ text "the "
        """
      let range2 = "[0↓,0↓]:4"
      self.testRoundTrip(
        range, content, documentManager,
        range1: rang1, doc1: doc1, range2: range2)
    }

    // (non-text, text)
    do {
      let content = [
        EmphasisNode([TextNode("jumps ")]),
        TextNode("over "),
      ]
      let documentManager = createDocumentManager()
      let rang1 = "[0↓,0↓]:4..<[0↓,2↓]:5"
      let doc1 = """
        root
        └ heading
          ├ text "fox "
          ├ emphasis
          │ └ text "jumps "
          └ text "over the "
        """
      let range2 = "[0↓,0↓]:4"
      self.testRoundTrip(
        range, content, documentManager,
        range1: rang1, doc1: doc1, range2: range2)
    }

    // (text, text)
    do {
      let content = [
        TextNode("jumps "),
        EmphasisNode([TextNode("gaily ")]),
        TextNode("over "),
      ]
      let documentManager = createDocumentManager()
      let rang1 = "[0↓,0↓]:4..<[0↓,2↓]:5"
      let doc1 = """
        root
        └ heading
          ├ text "fox jumps "
          ├ emphasis
          │ └ text "gaily "
          └ text "over the "
        """
      let range2 = "[0↓,0↓]:4"
      self.testRoundTrip(
        range, content, documentManager,
        range1: rang1, doc1: doc1, range2: range2)
    }
  }

  /// Insert inline content into a location inside a paragraph container.
  @Test
  func test_insertInlineContent_paragraphContainer_empty() throws {
    let documentManager = {
      let rootNode = RootNode()
      return createDocumentManager(rootNode)
    }()

    let range = {
      let path: [RohanIndex] = []
      let location = TextLocation(path, 0)
      return RhTextRange(location)
    }()
    let content = [
      EmphasisNode([TextNode("the quick brown ")]),
      TextNode("fox"),
    ]
    let range1 = "[0↓]:0..<[]:1"
    let doc1 = """
      root
      └ paragraph
        ├ emphasis
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

    let range = {
      let path: [RohanIndex] = []
      let location = TextLocation(path, 1)
      return RhTextRange(location)
    }()
    let content = [
      EmphasisNode([TextNode("fox ")]),
      TextNode("jumps over the lazy dog"),
    ]
    let range1 = "[1↓]:0..<[]:2"
    let doc1 = """
      root
      ├ paragraph
      │ └ text "the quick brown "
      └ paragraph
        ├ emphasis
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

    let range = {
      let location = TextLocation([], 0)
      return RhTextRange(location)
    }()
    let content = [
      TextNode("the "),
      EmphasisNode([TextNode("quick brown ")]),
    ]

    let range1 = "[0↓,0↓]:0..<[0↓,2↓]:0"
    let doc1 = """
      root
      └ paragraph
        ├ text "the "
        ├ emphasis
        │ └ text "quick brown "
        └ text "fox over the lazy dog"
      """
    let range2 = "[0↓,0↓]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)

    // TODO: add test for the case where the node is non-element
  }

  /// Insert inline content into a location inside an element node.
  @Test
  func test_insertInlineContent_elementNode_empty() throws {
    let documentManager = {
      let rootNode = RootNode([HeadingNode(level: 1, [])])
      return self.createDocumentManager(rootNode)
    }()

    let range = {
      let path: [RohanIndex] = [
        .index(0)  // heading
      ]
      let location = TextLocation(path, 0)
      return RhTextRange(location)
    }()

    let content = [
      EmphasisNode([TextNode("the quick brown ")]),
      TextNode("fox"),
    ]

    let range1 = "[0↓]:0..<[0↓,1↓]:3"
    let doc1 = """
      root
      └ heading
        ├ emphasis
        │ └ text "the quick brown "
        └ text "fox"
      """
    let range2 = "[0↓]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// Insert inline content into a location inside an element node.
  @Test
  func test_insertInlineContent_elementNode_end() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("the quick brown ")])
      ])
      return self.createDocumentManager(rootNode)
    }

    let range = {
      let path: [RohanIndex] = [
        .index(0)  // heading
      ]
      let location = TextLocation(path, 1)
      return RhTextRange(location)
    }()

    do {
      let documentManager = createDocumentManager()
      let content = [
        EmphasisNode([TextNode("jumps over ")]),
        TextNode("the lazy dog"),
      ]

      let range1 = "[0↓,0↓]:16..<[0↓,2↓]:12"
      let doc1 = """
        root
        └ heading
          ├ text "the quick brown "
          ├ emphasis
          │ └ text "jumps over "
          └ text "the lazy dog"
        """
      let range2 = "[0↓,0↓]:16"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {
      let documentManager = createDocumentManager()
      let content = [
        TextNode("jumps over "),
        EmphasisNode([TextNode("the lazy dog")]),
      ]

      let range1 = "[0↓,0↓]:16..<[0↓]:2"
      let doc1 = """
        root
        └ heading
          ├ text "the quick brown jumps over "
          └ emphasis
            └ text "the lazy dog"
        """
      let range2 = "[0↓,0↓]:16"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  @Test
  func test_insertInlineContent_elementNode_beginning() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("jumps over the lazy dog")])
      ])
      return self.createDocumentManager(rootNode)
    }()

    let range = {
      let path: [RohanIndex] = [
        .index(0)  // heading
      ]
      let location = TextLocation(path, 0)
      return RhTextRange(location)
    }()

    let content = [
      TextNode("the "),
      EmphasisNode([TextNode("quick brown ")]),
      TextNode("fox "),
    ]

    let range1 = "[0↓,0↓]:0..<[0↓,2↓]:4"
    let doc1 = """
      root
      └ heading
        ├ text "the "
        ├ emphasis
        │ └ text "quick brown "
        └ text "fox jumps over the lazy dog"
      """
    let range2 = "[0↓,0↓]:0"
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
          level: 1,
          [
            TextNode("quick brown "),
            EmphasisNode([TextNode("over ")]),
            TextNode("dog"),
          ])
      ])
      let documentManager = self.createDocumentManager(rootNode)
      return documentManager
    }

    // (previous is text, first-to-insert is text)
    do {
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(0)  // heading
        ]
        let location = TextLocation(path, 1)
        return RhTextRange(location)
      }()
      let content = [
        TextNode("fox "),
        EmphasisNode([TextNode("jumps ")]),
      ]

      let range1 = "[0↓,0↓]:12..<[0↓]:2"
      let doc1 = """
        root
        └ heading
          ├ text "quick brown fox "
          ├ emphasis
          │ └ text "jumps "
          ├ emphasis
          │ └ text "over "
          └ text "dog"
        """
      let range2 = "[0↓,0↓]:12"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // (last-to-insert is text, next is text)
    do {
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(0)  // heading
        ]
        let location = TextLocation(path, 2)
        return RhTextRange(location)
      }()
      let content = [
        EmphasisNode([TextNode("the ")]),
        TextNode("lazy "),
      ]

      let range1 = "[0↓]:2..<[0↓,3↓]:5"
      let doc1 = """
        root
        └ heading
          ├ text "quick brown "
          ├ emphasis
          │ └ text "over "
          ├ emphasis
          │ └ text "the "
          └ text "lazy dog"
        """
      let range2 = "[0↓,2↓]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // otherwise
    do {
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(0)  // heading
        ]
        let location = TextLocation(path, 2)
        return RhTextRange(location)
      }()
      let content = [
        EmphasisNode([TextNode("the lazy ")])
      ]

      let range1 = "[0↓]:2..<[0↓,3↓]:0"
      let doc1 = """
        root
        └ heading
          ├ text "quick brown "
          ├ emphasis
          │ └ text "over "
          ├ emphasis
          │ └ text "the lazy "
          └ text "dog"
        """
      let range2 = "[0↓,2↓]:0"
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
            isBlock: false,
            nucleus: [
              ApplyNode(
                CompiledSamples.bifun,
                [[ApplyNode(CompiledSamples.bifun, [[TextNode("m+1")]])!]])!
            ])
        ])
      ])
      return createDocumentManager(rootNode)
    }()

    let range = {
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // apply
        .argumentIndex(0),  // argument 0
        .index(0),  // apply
        .argumentIndex(0),  // argument 0
      ]
      let location = TextLocation(path, 0)
      return RhTextRange(location)
    }()

    let content = [
      FractionNode(numerator: [TextNode("m")], denominator: [TextNode("n")]),
      TextNode("+"),
    ]

    let range1 = "[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒]:0..<[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,1↓]:1"

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
                │     │ ├ fraction
                │     │ │ ├ numerator
                │     │ │ │ └ text "m"
                │     │ │ └ denominator
                │     │ │   └ text "n"
                │     │ └ text "+m+1"
                │     ├ text ","
                │     ├ variable #0
                │     │ ├ fraction
                │     │ │ ├ numerator
                │     │ │ │ └ text "m"
                │     │ │ └ denominator
                │     │ │   └ text "n"
                │     │ └ text "+m+1"
                │     └ text ")"
                ├ text ","
                ├ variable #0
                │ └ template(bifun)
                │   ├ argument #0 (x2)
                │   └ content
                │     ├ text "f("
                │     ├ variable #0
                │     │ ├ fraction
                │     │ │ ├ numerator
                │     │ │ │ └ text "m"
                │     │ │ └ denominator
                │     │ │   └ text "n"
                │     │ └ text "+m+1"
                │     ├ text ","
                │     ├ variable #0
                │     │ ├ fraction
                │     │ │ ├ numerator
                │     │ │ │ └ text "m"
                │     │ │ └ denominator
                │     │ │   └ text "n"
                │     │ └ text "+m+1"
                │     └ text ")"
                └ text ")"
      """
    let range2 = "[0↓,0↓,nucleus,0↓,0⇒,0↓,0⇒,0↓]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }
}
