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
    let rootNode = RootNode([
      ParagraphNode([TextNode("hello ")]),
      HeadingNode(level: 1, [TextNode("the quick brown ")]),
    ])

    let documentManager = createDocumentManager(rootNode)
    let location = {
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
    let result = documentManager.replaceContents(in: location, with: content)
    assert(result.isSuccess)
    let range = result.success()!
    #expect("\(range.location)" == "[0↓,0↓]:6")
    #expect("\(range.endLocation)" == "[1↓]:1")
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
  }

  /// Insert paragraph nodes into a location inside a text node.
  @Test
  func test_insertParagraphNodes_textNode_beginning() throws {
    let rootNode = RootNode([
      ParagraphNode([TextNode("world")]),
      HeadingNode(level: 1, [TextNode("the quick brown ")]),
    ])

    let documentManager = createDocumentManager(rootNode)
    let location = {
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
    let result = documentManager.replaceContents(in: location, with: content)
    assert(result.isSuccess)
    let range = result.success()!
    #expect("\(range.location)" == "[0↓,0↓]:0")
    #expect("\(range.endLocation)" == "[1↓,0↓]:6")
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

    let location = {
      let indices: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(indices, "hello ".stringLength)
      return RhTextRange(location)
    }()

    // insert a single paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([
          EmphasisNode([TextNode("good ")]),
          TextNode("and bad "),
        ])
      ]
      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[0↓,0↓]:6")
      #expect("\(range.endLocation)" == "[0↓,2↓]:8")
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
    }

    // insert a single non-paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")])
      ]
      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:1")
      #expect("\(range.endLocation)" == "[]:2")
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
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, non-par)
    do {
      let documentManager = createDocumentManager()
      let conent = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        HeadingNode(level: 1, [TextNode("good ")]),
      ]
      let result = documentManager.replaceContents(in: location, with: conent)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:1")
      #expect("\(range.endLocation)" == "[]:4")
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
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, par)
    do {
      let documentManager = createDocumentManager()
      let conent = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        ParagraphNode([TextNode("good ")]),
      ]
      let result = documentManager.replaceContents(in: location, with: conent)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:1")
      #expect("\(range.endLocation)" == "[3↓,0↓]:5")
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
    }

    // insert multiple nodes with (beginning, end) ~ (par, non-par)
    do {
      let documentManager = createDocumentManager()
      let conent = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        HeadingNode(level: 1, [TextNode("good ")]),
      ]
      let result = documentManager.replaceContents(in: location, with: conent)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[0↓,0↓]:6")
      #expect("\(range.endLocation)" == "[]:3")
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
    }

    // insert multiple nodes with (beginning, end) ~ (par, par)
    do {
      let documentManager = createDocumentManager()
      let conent = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        ParagraphNode([TextNode("good ")]),
      ]
      let result = documentManager.replaceContents(in: location, with: conent)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[0↓,0↓]:6")
      #expect("\(range.endLocation)" == "[2↓,0↓]:5")
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
    }
  }

  /// Insert paragraph nodes into a location inside a paragraph container.
  @Test
  func test_insertParagraphNodes_paragraphContainer_empty() throws {
    let rootNode = RootNode([])
    let documentManager = createDocumentManager(rootNode)
    let location = {
      let location = TextLocation([], 0)
      return RhTextRange(location)
    }()
    let content = [
      ParagraphNode([TextNode("hello")]),
      ParagraphNode([TextNode("world")]),
    ]
    let result = documentManager.replaceContents(in: location, with: content)
    assert(result.isSuccess)
    let range = result.success()!
    #expect("\(range.location)" == "[]:0")
    #expect("\(range.endLocation)" == "[]:2")
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ paragraph
        │ └ text "hello"
        └ paragraph
          └ text "world"
        """)
  }

  /// Insert paragraph nodes into a location inside a paragraph container.
  @Test
  func test_insertParagraphNodes_paragraphContainer_end() throws {
    // last node is mergeable with the new content
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("hello world")]),
        ParagraphNode([TextNode("bonjour ")]),
      ])
      let documentManager = createDocumentManager(rootNode)
      let location = {
        let location = TextLocation([], 2)
        return RhTextRange(location)
      }()
      let content = [
        ParagraphNode([TextNode("Monsieur")])
      ]
      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[1↓,0↓]:8")
      #expect("\(range.endLocation)" == "[]:2")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ heading
          │ └ text "hello world"
          └ paragraph
            └ text "bonjour Monsieur"
          """)
    }
    // last node is not mergeable with the new content
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("hello world")]),
        ParagraphNode([TextNode("bonjour ")]),
      ])
      let documentManager = createDocumentManager(rootNode)
      let location = {
        let location = TextLocation([], 2)
        return RhTextRange(location)
      }()
      let content = [
        HeadingNode(level: 1, [TextNode("Monsieur")])
      ]
      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:2")
      #expect("\(range.endLocation)" == "[]:3")
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
    }
  }

  /// Insert paragraph nodes into a location inside a paragraph container.
  @Test
  func test_insertParagraphNodes_paragraphContainer_beginningOrMiddle() throws {
    // last node-to-insert is mergeable with the first node to the right of the location
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("world")]),
        ParagraphNode([TextNode("Monsieur")]),
      ])
      let documentManager = createDocumentManager(rootNode)
      let location = {
        let location = TextLocation([], 1)
        return RhTextRange(location)
      }()
      let content = [
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
        ParagraphNode([TextNode("hello ")]),
      ]

      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:1")
      #expect("\(range.endLocation)" == "[2↓,0↓]:6")
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
    }

    // last node-to-insert is not mergeable with the first node to the right of the location
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("world")]),
        ParagraphNode([TextNode("Monsieur")]),
      ])
      let documentManager = createDocumentManager(rootNode)
      let location = {
        let location = TextLocation([], 0)
        return RhTextRange(location)
      }()
      let content = [
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
        ParagraphNode([TextNode("hello ")]),
      ]

      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:0")
      #expect("\(range.endLocation)" == "[]:2")
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
    }
  }

  /// Insert paragraph nodes into a location inside an element node.
  @Test
  func test_insertParagraphNodes_elementNode_single() throws {
    // insert a single node that is mergeable with the target paragraph node
    do {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("Hello "),
          EmphasisNode([TextNode("world")]),
        ])
      ])
      let documentManager = createDocumentManager(rootNode)
      let location = {
        let indices: [RohanIndex] = [
          .index(0)  // paragraph
        ]
        let location = TextLocation(indices, 1)
        return RhTextRange(location)
      }()
      let content = [
        ParagraphNode([
          EmphasisNode([TextNode("tout le monde ")])
        ])
      ]

      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[0↓]:1")
      #expect("\(range.endLocation)" == "[0↓]:2")
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
    }

    do {
      let rootNode = RootNode([
        ParagraphNode([
          TextNode("Hello "),
          EmphasisNode([TextNode("world")]),
        ])
      ])
      let documentManager = createDocumentManager(rootNode)
      let location = {
        let indices: [RohanIndex] = [
          .index(0)  // paragraph
        ]
        let location = TextLocation(indices, 1)
        return RhTextRange(location)
      }()
      let content = [
        HeadingNode(level: 1, [EmphasisNode([TextNode("tout le monde")])])
      ]

      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:1")
      #expect("\(range.endLocation)" == "[]:2")
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

    let location = {
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
      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:1")
      #expect("\(range.endLocation)" == "[]:3")
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
    }

    // insert multiple nodes with (beginning, end) ~ (non-par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(level: 1, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
      ]
      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[]:1")
      #expect("\(range.endLocation)" == "[2↓,0↓]:9")
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
    }

    // insert multiple nodes with (beginning, end) ~ (par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        HeadingNode(level: 1, [TextNode("Guten Tag")]),
      ]
      let result = documentManager.replaceContents(in: location, with: content)
      assert(result.isSuccess)
      let range = result.success()!
      #expect("\(range.location)" == "[0↓,2↓]:0")
      #expect("\(range.endLocation)" == "[]:2")
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
    }

    // insert multiple nodes with (beginning, end) ~ (par, par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
      ]
      let result = documentManager.replaceContents(in: location, with: content)
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
}
