// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import Rohan

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
      let location = TextLocation(indices, "hello ".stringLength)
      return RhTextRange(location)
    }()
    let content = [
      ParagraphNode([TextNode("world")]),
      ParagraphNode([TextNode("Boujour")]),
    ]

    let (range1, deleted1) =
      DMUtils.replaceContents(in: range, with: content, documentManager)
    #expect("\(range1)" == "[0↓,0↓]:6..<[1↓,0↓]:7")
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "hello world"
        ├ paragraph
        │ └ text "Boujour"
        └ heading
          └ text "the quick brown "
        """)
    // revert
    let (range2, _) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓,0↓]:6")
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "hello "
        └ heading
          └ text "the quick brown "
        """)
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

    let (range1, deleted1) =
      DMUtils.replaceContents(in: range, with: content, documentManager)
    #expect("\(range1)" == "[0↓,0↓]:0..<[1↓,0↓]:6")
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "Guten Tag"
        ├ paragraph
        │ └ text "hello world"
        └ heading
          └ text "the quick brown "
        """)

    // revert
    let (range2, _) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓,0↓]:0")
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "world"
        └ heading
          └ text "the quick brown "
        """)
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
      let location = TextLocation(indices, "hello ".stringLength)
      return RhTextRange(location)
    }()

    let original = """
      root
      └ paragraph
        ├ text "hello world. "
        └ emphasis
          └ text "the quick brown fox"
      """

    // insert a single paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([
          EmphasisNode([TextNode("good ")]),
          TextNode("and bad "),
        ])
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,0↓]:6..<[0↓,2↓]:8")
      #expect(
        documentManager.prettyPrint() == """
          root
          └ paragraph
            ├ text "hello "
            ├ emphasis
            │ └ text "good "
            ├ text "and bad world. "
            └ emphasis
              └ text "the quick brown fox"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,0↓]:6")
      #expect(documentManager.prettyPrint() == original)
    }

    // insert a single non-paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")])
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,0↓]:6..<[2↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ └ text "hello "
          ├ heading
          │ └ text "nice "
          └ paragraph
            ├ text "world. "
            └ emphasis
              └ text "the quick brown fox"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,0↓]:6")
      #expect(documentManager.prettyPrint() == original)
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        HeadingNode(level: 1, [TextNode("good ")]),
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,0↓]:6..<[4↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
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
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,0↓]:6")
      #expect(documentManager.prettyPrint() == original)
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        ParagraphNode([TextNode("good ")]),
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,0↓]:6..<[3↓,0↓]:5")
      #expect(
        documentManager.prettyPrint() == """
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
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,0↓]:6")
      #expect(documentManager.prettyPrint() == original)
    }

    // insert multiple nodes with (beginning, end) ~ (par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        HeadingNode(level: 1, [TextNode("good ")]),
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,0↓]:6..<[3↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
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
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,0↓]:6")
      #expect(documentManager.prettyPrint() == original)
    }

    // insert multiple nodes with (beginning, end) ~ (par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        ParagraphNode([TextNode("good ")]),
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,0↓]:6..<[2↓,0↓]:5")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ └ text "hello nice "
          ├ paragraph
          │ └ text "Guten Tag"
          └ paragraph
            ├ text "good world. "
            └ emphasis
              └ text "the quick brown fox"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,0↓]:6")
      #expect(documentManager.prettyPrint() == original)
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
    let (range1, deleted1) =
      DMUtils.replaceContents(in: range, with: content, documentManager)
    #expect("\(range1)" == "[0↓,0↓]:0..<[1↓,0↓]:5")
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "hello"
        └ paragraph
          └ text "world"
        """)
    // revert
    let (range2, _) =
      DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
    #expect("\(range2)" == "[0↓]:0")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ paragraph
        """)
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

    let original = """
      root
      ├ heading
      │ └ text "hello world"
      └ paragraph
        └ text "bonjour "
      """

    // last node is mergeable with the new content
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("Monsieur")])
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[1↓,0↓]:8..<[1↓,0↓]:16")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "hello world"
          └ paragraph
            └ text "bonjour Monsieur"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[1↓,0↓]:8")
      #expect(documentManager.prettyPrint() == original)
    }
    // last node is not mergeable with the new content
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("Monsieur")])
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[]:2..<[]:3")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "hello world"
          ├ paragraph
          │ └ text "bonjour "
          └ heading
            └ text "Monsieur"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[1↓,0↓]:8")
      #expect(documentManager.prettyPrint() == original)
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
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[]:1..<[2↓,0↓]:6")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "world"
          ├ heading
          │ └ text "Guten Tag"
          └ paragraph
            └ text "hello Monsieur"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[1↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "world"
          └ paragraph
            └ text "Monsieur"
          """)
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
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[]:0..<[]:2")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "Guten Tag"
          ├ paragraph
          │ └ text "hello "
          ├ heading
          │ └ text "world"
          └ paragraph
            └ text "Monsieur"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "world"
          └ paragraph
            └ text "Monsieur"
          """)
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

    let original = """
      root
      └ paragraph
        ├ text "Hello "
        └ emphasis
          └ text "world"
      """

    // insert a single node that is mergeable with the target paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([
          EmphasisNode([TextNode("tout le monde ")])
        ])
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,0↓]:6..<[0↓]:2")
      #expect(
        documentManager.prettyPrint() == """
          root
          └ paragraph
            ├ text "Hello "
            ├ emphasis
            │ └ text "tout le monde "
            └ emphasis
              └ text "world"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,0↓]:6")
      #expect(documentManager.prettyPrint() == original)
    }

    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [EmphasisNode([TextNode("tout le monde")])])
      ]

      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,0↓]:6..<[2↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ └ text "Hello "
          ├ heading
          │ └ emphasis
          │   └ text "tout le monde"
          └ paragraph
            └ emphasis
              └ text "world"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,0↓]:6")
      #expect(documentManager.prettyPrint() == original)
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

    let original = """
      root
      └ paragraph
        ├ text "Hello "
        ├ emphasis
        │ └ text "world"
        └ text "!"
      """

    // insert multiple nodes with (beginning, end) ~ (non-par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓]:2..<[3↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
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
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,2↓]:0")
      #expect(documentManager.prettyPrint() == original)
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓]:2..<[2↓,0↓]:9")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ ├ text "Hello "
          │ └ emphasis
          │   └ text "world"
          ├ heading
          │ └ text "nice "
          └ paragraph
            └ text "Guten Tag!"
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,2↓]:0")
      #expect(documentManager.prettyPrint() == original)
    }

    // insert multiple nodes with (beginning, end) ~ (par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
      ]
      let (range1, deleted1) =
        DMUtils.replaceContents(in: range, with: content, documentManager)
      #expect("\(range1)" == "[0↓,2↓]:0..<[2↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
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
          """)
      // revert
      let (range2, _) =
        DMUtils.replaceContents(in: range1, with: deleted1, documentManager)
      #expect("\(range2)" == "[0↓,2↓]:0")
      #expect(documentManager.prettyPrint() == original)
    }

    // insert multiple nodes with (beginning, end) ~ (par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
      ]
      let result = documentManager.replaceContents(in: range, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[0↓,2↓]:0")
      #expect("\(range.endLocation)" == "[1↓,0↓]:9")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ ├ text "Hello "
          │ ├ emphasis
          │ │ └ text "world"
          │ └ text "nice "
          └ paragraph
            └ text "Guten Tag!"
          """)
    }
  }

  // TODO: add tests for inserting into ApplyNode
}
