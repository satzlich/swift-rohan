// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

final class InsertParagraphBreakTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func test_EmptyRoot() throws {
    let documentManager = {
      let rootNode = RootNode()
      return createDocumentManager(rootNode)
    }()

    let range = RhTextRange.parse("[]:0")!
    let nodes = documentManager.resolveInsertParagraphBreak(at: range)

    let range1 = "[↓0]:0..<[]:2"
    let doc1 = """
      root
      ├ paragraph
      └ paragraph
      """
    let range2 = "[]:0"
    testRoundTrip(
      range, nodes, documentManager,
      range1: range1, doc1: doc1, range2: range2)
  }

  @Test
  func test_Root() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([TextNode("Hello")]),
        ParagraphNode([TextNode("World")]),
      ])
      return self.createDocumentManager(rootNode)
    }

    do {  // at the beginning
      let documentManager = createDocumentManager()

      let range = RhTextRange.parse("[]:0")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓0]:0..<[↓1,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        ├ paragraph
        │ └ text "Hello"
        └ paragraph
          └ text "World"
        """
      let range2 = "[↓0,↓0]:0"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    do {
      let documentManager = createDocumentManager()

      let range = RhTextRange.parse("[]:1")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓1]:0..<[↓2,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Hello"
        ├ paragraph
        └ paragraph
          └ text "World"
        """
      let range2 = "[↓1,↓0]:0"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    do {
      let documentManager = createDocumentManager()

      let range = RhTextRange.parse("[]:2")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓2]:0..<[]:3"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Hello"
        ├ paragraph
        │ └ text "World"
        └ paragraph
        """
      let range2 = "[]:2"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  @Test
  func test_Element() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode([TextNode("Abc")]),
        ParagraphNode(
          [
            TextNode("Hello, "),
            TextStylesNode(.emph, [TextNode("world")]),
          ]),
        ParagraphNode([TextNode("Def")]),
      ])
      return self.createDocumentManager(rootNode)
    }

    do {
      let documentManager = createDocumentManager()
      // paragraph -> <offset>
      let range = RhTextRange.parse("[↓1]:0")!

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓1]:0..<[↓2,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Abc"
        ├ paragraph
        ├ paragraph
        │ ├ text "Hello, "
        │ └ emph
        │   └ text "world"
        └ paragraph
          └ text "Def"
        """
      let range2 = "[↓1,↓0]:0"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    do {
      let documentManager = createDocumentManager()

      // paragraph -> <offset>
      let range = RhTextRange.parse("[↓1]:1")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓1,↓0]:7..<[↓2]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Abc"
        ├ paragraph
        │ └ text "Hello, "
        ├ paragraph
        │ └ emph
        │   └ text "world"
        └ paragraph
          └ text "Def"
        """
      let range2 = "[↓1,↓0]:7"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {
      let documentManager = createDocumentManager()

      // paragraph -> <offset>
      let range = RhTextRange.parse("[↓1]:2")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓1]:2..<[↓2]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Abc"
        ├ paragraph
        │ ├ text "Hello, "
        │ └ emph
        │   └ text "world"
        ├ paragraph
        └ paragraph
          └ text "Def"
        """
      let range2 = "[↓1]:2"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  @Test
  func test_Text() throws {
    func createDocumentManager() -> DocumentManager {
      let rootNode = RootNode([
        ParagraphNode(
          [
            TextNode("The "),
            TextStylesNode(.emph, [TextNode("quick brown ")]),
            TextNode("fox"),
          ])
      ])
      return self.createDocumentManager(rootNode)
    }

    do {  // at the beginning
      let documentManager = createDocumentManager()
      // paragraph -> text -> <offset>
      let range = RhTextRange.parse("[↓0,↓0]:0")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓0]:0..<[↓1,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        └ paragraph
          ├ text "The "
          ├ emph
          │ └ text "quick brown "
          └ text "fox"
        """
      let range2 = "[↓0,↓0]:0"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {  // in the middle
      let documentManager = createDocumentManager()

      // paragraph -> text -> <offset>
      let offset = "Th".length
      let range = RhTextRange.parse("[↓0,↓0]:\(offset)")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓0,↓0]:2..<[↓1,↓0]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Th"
        └ paragraph
          ├ text "e "
          ├ emph
          │ └ text "quick brown "
          └ text "fox"
        """
      let range2 = "[↓0,↓0]:2"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {  // at the end
      let documentManager = createDocumentManager()

      let offset = "The ".length
      // paragraph -> text -> <offset>
      let range = RhTextRange.parse("[↓0,↓0]:\(offset)")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓0,↓0]:4..<[↓1]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "The "
        └ paragraph
          ├ emph
          │ └ text "quick brown "
          └ text "fox"
        """
      let range2 = "[↓0,↓0]:4"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {  // at paragraph end
      let documentManager = createDocumentManager()

      // paragraph -> text -> <offset>
      let offset = "fox".length
      let range = RhTextRange.parse("[↓0,↓2]:\(offset)")!
      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[↓0,↓2]:3..<[↓1]:0"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "The "
        │ ├ emph
        │ │ └ text "quick brown "
        │ └ text "fox"
        └ paragraph
        """
      let range2 = "[↓0,↓2]:3"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
  }

  @Test
  func test_Emphasis() throws {
    let documentManager = {
      let rootNode = RootNode([
        HeadingNode(
          level: 1,
          [
            TextNode("The "),
            TextStylesNode(.emph, [TextNode("quick brown ")]),
            TextNode("fox"),
          ])
      ])
      return createDocumentManager(rootNode)
    }()

    // heading -> emphasis -> text -> <offset>
    let offset = "quick ".length
    let range = RhTextRange.parse("[↓0,↓1,↓0]:\(offset)")!
    let nodes = documentManager.resolveInsertParagraphBreak(at: range)
    let result = documentManager.replaceContents(in: range, with: nodes)
    #expect(result.isFailure)
  }
}
