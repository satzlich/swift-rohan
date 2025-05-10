// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

final class InsertParagraphNodesTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  /// Insert paragraph nodes into a location inside a text node.
  @Test
  func test_insertParagraphNodes_textNode_end() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([TextNode("hello ")]),
        HeadingNode(level: 1, [TextNode("the quick brown ")]),
      ])
      return self.createDocumentManager(rootNode)
    }()

    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(indices, "hello ".length)
      return RhTextRange(location)
    }()
    let content = [
      ParagraphNode([TextNode("world")]),
      ParagraphNode([TextNode("Boujour")]),
    ]
    let range1 = "[↓0,↓0]:6..<[↓1,↓0]:7"
    let doc1 = """
      root
      ├ paragraph
      │ └ text "hello world"
      ├ paragraph
      │ └ text "Boujour"
      └ heading
        └ text "the quick brown "
      """
    let range2 = "[↓0,↓0]:6"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// Insert paragraph nodes into a location inside a text node.
  @Test
  func test_insertParagraphNodes_textNode_beginning() throws {
    let documentManager = {
      let rootNode = RootNode([
        ParagraphNode([TextNode("world")]),
        HeadingNode(level: 1, [TextNode("the quick brown ")]),
      ])
      return createDocumentManager(rootNode)
    }()
    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(indices, 0)
      return RhTextRange(location)
    }()
    let content = [
      ParagraphNode([TextNode("Guten Tag")]),
      ParagraphNode([TextNode("hello ")]),
    ]

    let range1 = "[↓0,↓0]:0..<[↓1,↓0]:6"
    let doc1 = """
      root
      ├ paragraph
      │ └ text "Guten Tag"
      ├ paragraph
      │ └ text "hello world"
      └ heading
        └ text "the quick brown "
      """
    let range2 = "[↓0,↓0]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// Insert paragraph nodes into a location inside a text node.
  @Test
  func test_insertParagraphNodes_textNode_mid() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("hello world. "),
          EmphasisNode([TextNode("the quick brown fox")]),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    let range = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(indices, "hello ".length)
      return RhTextRange(location)
    }()

    // insert a single paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([
          TextNode("good and bad ")
        ])
      ]
      let range1 = "[↓0,↓0]:6..<[↓0,↓0]:19"
      let doc1 = """
        root
        └ paragraph
          ├ text "hello good and bad world. "
          └ emphasis
            └ text "the quick brown fox"
        """
      let range2 = "[↓0,↓0]:6"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // insert a single non-paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")])
      ]
      let range1 = "[↓0,↓0]:6..<[↓2,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "hello "
        ├ heading
        │ └ text "nice "
        └ paragraph
          ├ text "world. "
          └ emphasis
            └ text "the quick brown fox"
        """
      let range2 = "[↓0,↓0]:6"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        HeadingNode(level: 1, [TextNode("good ")]),
      ]

      let range1 = "[↓0,↓0]:6..<[↓4,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "hello "
        ├ heading
        │ └ text "nice "
        ├ paragraph
        │ └ text "Guten Tag"
        ├ heading
        │ └ text "good "
        └ paragraph
          ├ text "world. "
          └ emphasis
            └ text "the quick brown fox"
        """
      let range2 = "[↓0,↓0]:6"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        ParagraphNode([TextNode("good ")]),
      ]
      let range1 = "[↓0,↓0]:6..<[↓3,↓0]:5"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "hello "
        ├ heading
        │ └ text "nice "
        ├ paragraph
        │ └ text "Guten Tag"
        └ paragraph
          ├ text "good world. "
          └ emphasis
            └ text "the quick brown fox"
        """
      let range2 = "[↓0,↓0]:6"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // insert multiple nodes with (beginning, end) ~ (par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        HeadingNode(level: 1, [TextNode("good ")]),
      ]
      let range1 = "[↓0,↓0]:6..<[↓3,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "hello nice "
        ├ paragraph
        │ └ text "Guten Tag"
        ├ heading
        │ └ text "good "
        └ paragraph
          ├ text "world. "
          └ emphasis
            └ text "the quick brown fox"
        """
      let range2 = "[↓0,↓0]:6"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // insert multiple nodes with (beginning, end) ~ (par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        ParagraphNode([TextNode("good ")]),
      ]
      let range1 = "[↓0,↓0]:6..<[↓2,↓0]:5"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "hello nice "
        ├ paragraph
        │ └ text "Guten Tag"
        └ paragraph
          ├ text "good world. "
          └ emphasis
            └ text "the quick brown fox"
        """
      let range2 = "[↓0,↓0]:6"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  /// Insert paragraph nodes into a location inside a paragraph container.
  @Test
  func test_insertParagraphNodes_paragraphContainer_empty() throws {
    let documentManager = {
      let rootNode = RootNode([])
      return self.createDocumentManager(rootNode)
    }()
    let range = {
      let location = TextLocation([], 0)
      return RhTextRange(location)
    }()
    let content = [
      ParagraphNode([TextNode("hello")]),
      ParagraphNode([TextNode("world")]),
    ]

    let range1 = "[↓0,↓0]:0..<[]:2"
    let doc1 = """
      root
      ├ paragraph
      │ └ text "hello"
      └ paragraph
        └ text "world"
      """
    let range2 = "[]:0"
    self.testRoundTrip(
      range, content, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  /// Insert paragraph nodes into a location inside a paragraph container.
  @Test
  func test_insertParagraphNodes_paragraphContainer_end() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("hello world")]),
        ParagraphNode([TextNode("bonjour ")]),
      ])
      return self.createDocumentManager(rootNode)
    }

    let range = {
      let location = TextLocation([], 2)
      return RhTextRange(location)
    }()

    // last node is mergeable with the new content
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("Monsieur")])
      ]
      let range1 = "[↓2,↓0]:0..<[]:3"
      let doc1 = """
        root
        ├ heading
        │ └ text "hello world"
        ├ paragraph
        │ └ text "bonjour "
        └ paragraph
          └ text "Monsieur"
        """
      let range2 = "[]:2"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    // last node is not mergeable with the new content
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("Monsieur")])
      ]
      let range1 = "[]:2..<[]:3"
      let doc1 = """
        root
        ├ heading
        │ └ text "hello world"
        ├ paragraph
        │ └ text "bonjour "
        └ heading
          └ text "Monsieur"
        """
      let range2 = "[]:2"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  /// Insert paragraph nodes into a location inside a paragraph container.
  @Test
  func test_insertParagraphNodes_paragraphContainer_beginningOrMiddle() throws {
    // last node-to-insert is mergeable with the first node to the right of
    // the location
    do {
      let documentManager = {
        let rootNode = RootNode([
          HeadingNode(level: 1, [TextNode("world")]),
          ParagraphNode([TextNode("Monsieur")]),
        ])
        return createDocumentManager(rootNode)
      }()
      let range = {
        let location = TextLocation([], 1)
        return RhTextRange(location)
      }()
      let content = [
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
        ParagraphNode([TextNode("hello ")]),
      ]

      let range1 = "[]:1..<[↓2,↓0]:6"
      let doc1 = """
        root
        ├ heading
        │ └ text "world"
        ├ heading
        │ └ text "Guten Tag"
        └ paragraph
          └ text "hello Monsieur"
        """
      let range2 = "[↓1,↓0]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // last node-to-insert is not mergeable with the first node to the right
    // of the location
    do {
      let documentManager = {
        let rootNode = RootNode([
          HeadingNode(level: 1, [TextNode("world")]),
          ParagraphNode([TextNode("Monsieur")]),
        ])
        return createDocumentManager(rootNode)
      }()
      let range = {
        let location = TextLocation([], 0)
        return RhTextRange(location)
      }()
      let content = [
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
        ParagraphNode([TextNode("hello ")]),
      ]

      let range1 = "[]:0..<[]:2"
      let doc1 = """
        root
        ├ heading
        │ └ text "Guten Tag"
        ├ paragraph
        │ └ text "hello "
        ├ heading
        │ └ text "world"
        └ paragraph
          └ text "Monsieur"
        """
      let range2 = "[]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  /// Insert paragraph nodes into a location inside an element node.
  @Test
  func test_insertParagraphNodes_elementNode_single() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("Hello "),
          EmphasisNode([TextNode("world")]),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    let range = {
      let indices: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let location = TextLocation(indices, 1)
      return RhTextRange(location)
    }()

    // insert a single node that is mergeable with the target paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([
          EmphasisNode([TextNode("tout le monde ")])
        ])
      ]

      let range1 = "[↓0,↓0]:6..<[↓0]:2"
      let doc1 = """
        root
        └ paragraph
          ├ text "Hello "
          ├ emphasis
          │ └ text "tout le monde "
          └ emphasis
            └ text "world"
        """
      let range2 = "[↓0,↓0]:6"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [EmphasisNode([TextNode("tout le monde")])])
      ]
      let range1 = "[↓0,↓0]:6..<[↓2]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Hello "
        ├ heading
        │ └ emphasis
        │   └ text "tout le monde"
        └ paragraph
          └ emphasis
            └ text "world"
        """
      let range2 = "[↓0,↓0]:6"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  /// Insert paragraph nodes into a location inside an element node.
  @Test
  func test_insertParagraphNodes_elementNode_multiple() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("Hello "),
          EmphasisNode([TextNode("world")]),
          TextNode("!"),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    let range = {
      let indices: [RohanIndex] = [
        .index(0)  // paragraph
      ]
      let location = TextLocation(indices, 2)
      return RhTextRange(location)
    }()

    // insert multiple nodes with (beginning, end) ~ (non-par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
      ]
      let range1 = "[↓0]:2..<[↓3,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "Hello "
        │ └ emphasis
        │   └ text "world"
        ├ heading
        │ └ text "nice "
        ├ heading
        │ └ text "Guten Tag"
        └ paragraph
          └ text "!"
        """
      let range2 = "[↓0,↓2]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
      ]
      let range1 = "[↓0]:2..<[↓2,↓0]:9"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "Hello "
        │ └ emphasis
        │   └ text "world"
        ├ heading
        │ └ text "nice "
        └ paragraph
          └ text "Guten Tag!"
        """
      let range2 = "[↓0,↓2]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // insert multiple nodes with (beginning, end) ~ (par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
      ]
      let range1 = "[↓0,↓2]:0..<[↓2,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "Hello "
        │ ├ emphasis
        │ │ └ text "world"
        │ └ text "nice "
        ├ heading
        │ └ text "Guten Tag"
        └ paragraph
          └ text "!"
        """
      let range2 = "[↓0,↓2]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    // insert multiple nodes with (beginning, end) ~ (par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
      ]
      let range1 = "[↓0,↓2]:0..<[↓1,↓0]:9"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "Hello "
        │ ├ emphasis
        │ │ └ text "world"
        │ └ text "nice "
        └ paragraph
          └ text "Guten Tag!"
        """
      let range2 = "[↓0,↓2]:0"
      self.testRoundTrip(
        range, content, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  // TODO: add tests for inserting into ApplyNode
}
