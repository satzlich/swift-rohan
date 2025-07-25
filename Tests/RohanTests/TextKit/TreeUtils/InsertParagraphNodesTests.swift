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
        HeadingNode(.sectionAst, [TextNode("the quick brown ")]),
      ])
      return self.createDocumentManager(rootNode)
    }()

    let offset = "hello ".length
    // paragraph -> text -> <offset>
    let range = RhTextRange.parse("[↓0,↓0]:\(offset)")!
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
        HeadingNode(.sectionAst, [TextNode("the quick brown ")]),
      ])
      return createDocumentManager(rootNode)
    }()

    // paragraph -> text -> <0>
    let range = RhTextRange.parse("[↓0,↓0]:0")!
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
          TextStylesNode(.emph, [TextNode("the quick brown fox")]),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    let offset = "hello ".length
    // paragraph -> text -> <offset>
    let range = RhTextRange.parse("[↓0,↓0]:\(offset)")!

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
          └ emph
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
        HeadingNode(.sectionAst, [TextNode("nice ")])
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
          └ emph
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
        HeadingNode(.sectionAst, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
        HeadingNode(.sectionAst, [TextNode("good ")]),
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
          └ emph
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
        HeadingNode(.sectionAst, [TextNode("nice ")]),
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
          └ emph
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
        HeadingNode(.sectionAst, [TextNode("good ")]),
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
          └ emph
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
          └ emph
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

    let range = RhTextRange.parse("[]:0")!
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
        HeadingNode(.sectionAst, [TextNode("hello world")]),
        ParagraphNode([TextNode("bonjour ")]),
      ])
      return self.createDocumentManager(rootNode)
    }

    let range = RhTextRange.parse("[]:2")!

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
        HeadingNode(.sectionAst, [TextNode("Monsieur")])
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
          HeadingNode(.sectionAst, [TextNode("world")]),
          ParagraphNode([TextNode("Monsieur")]),
        ])
        return createDocumentManager(rootNode)
      }()

      let range = RhTextRange.parse("[]:1")!
      let content = [
        HeadingNode(.sectionAst, [TextNode("Guten Tag")]),
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
          HeadingNode(.sectionAst, [TextNode("world")]),
          ParagraphNode([TextNode("Monsieur")]),
        ])
        return createDocumentManager(rootNode)
      }()

      let range = RhTextRange.parse("[]:0")!
      let content = [
        HeadingNode(.sectionAst, [TextNode("Guten Tag")]),
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
          TextStylesNode(.emph, [TextNode("world")]),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    let range = RhTextRange.parse("[↓0]:1")!
    // insert a single node that is mergeable with the target paragraph node
    do {
      let documentManager = createDocumentManager()
      let content = [
        ParagraphNode([
          TextStylesNode(.emph, [TextNode("tout le monde ")])
        ])
      ]

      let range1 = "[↓0,↓0]:6..<[↓0]:2"
      let doc1 = """
        root
        └ paragraph
          ├ text "Hello "
          ├ emph
          │ └ text "tout le monde "
          └ emph
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
        HeadingNode(.sectionAst, [TextStylesNode(.emph, [TextNode("tout le monde")])])
      ]
      let range1 = "[↓0,↓0]:6..<[↓2]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Hello "
        ├ heading
        │ └ emph
        │   └ text "tout le monde"
        └ paragraph
          └ emph
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
          TextStylesNode(.emph, [TextNode("world")]),
          TextNode("!"),
        ])
      ])
      return self.createDocumentManager(rootNode)
    }

    // paragraph -> <offset>
    let range = RhTextRange.parse("[↓0]:2")!

    // insert multiple nodes with (beginning, end) ~ (non-par, non-par)
    do {
      let documentManager = createDocumentManager()
      let content = [
        HeadingNode(.sectionAst, [TextNode("nice ")]),
        HeadingNode(.sectionAst, [TextNode("Guten Tag")]),
      ]
      let range1 = "[↓0]:2..<[↓3,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "Hello "
        │ └ emph
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
        HeadingNode(.sectionAst, [TextNode("nice ")]),
        ParagraphNode([TextNode("Guten Tag")]),
      ]
      let range1 = "[↓0]:2..<[↓2,↓0]:9"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "Hello "
        │ └ emph
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
        HeadingNode(.sectionAst, [TextNode("Guten Tag")]),
      ]
      let range1 = "[↓0,↓2]:0..<[↓2,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "Hello "
        │ ├ emph
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
        │ ├ emph
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
