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
    let range = RhTextRange(TextLocation([], 0))
    let nodes = documentManager.resolveInsertParagraphBreak(at: range)

    let range1 = "[0↓]:0..<[]:2"
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
      let range = RhTextRange(TextLocation([], 0))

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[0↓]:0..<[1↓,0↓]:0"
      let doc1 = """
        root
        ├ paragraph
        ├ paragraph
        │ └ text "Hello"
        └ paragraph
          └ text "World"
        """
      let range2 = "[0↓,0↓]:0"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    do {
      let documentManager = createDocumentManager()
      let range = RhTextRange(TextLocation([], 1))

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[1↓]:0..<[2↓,0↓]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Hello"
        ├ paragraph
        └ paragraph
          └ text "World"
        """
      let range2 = "[1↓,0↓]:0"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    do {
      let documentManager = createDocumentManager()
      let range = RhTextRange(TextLocation([], 2))

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[2↓]:0..<[]:3"
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
            EmphasisNode([TextNode("world")]),
          ]),
        ParagraphNode([TextNode("Def")]),
      ])
      return self.createDocumentManager(rootNode)
    }

    do {
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(1)  // paragraph
        ]
        return RhTextRange(TextLocation(path, 0))
      }()

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[1↓]:0..<[2↓,0↓]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Abc"
        ├ paragraph
        ├ paragraph
        │ ├ text "Hello, "
        │ └ emphasis
        │   └ text "world"
        └ paragraph
          └ text "Def"
        """
      let range2 = "[1↓,0↓]:0"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }
    do {
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(1)  // paragraph
        ]
        let location = TextLocation(path, 1)
        return RhTextRange(location)
      }()

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[1↓,0↓]:7..<[2↓]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Abc"
        ├ paragraph
        │ └ text "Hello, "
        ├ paragraph
        │ └ emphasis
        │   └ text "world"
        └ paragraph
          └ text "Def"
        """
      let range2 = "[1↓,0↓]:7"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(1)  // heading
        ]
        let location = TextLocation(path, 2)
        return RhTextRange(location)
      }()

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[1↓]:2..<[2↓]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Abc"
        ├ paragraph
        │ ├ text "Hello, "
        │ └ emphasis
        │   └ text "world"
        ├ paragraph
        └ paragraph
          └ text "Def"
        """
      let range2 = "[1↓]:2"

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
            EmphasisNode([TextNode("quick brown ")]),
            TextNode("fox"),
          ])
      ])
      return self.createDocumentManager(rootNode)
    }

    do {  // at the beginning
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(0),  // paragraph
          .index(0),  // text
        ]
        let location = TextLocation(path, 0)
        return RhTextRange(location)
      }()

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[0↓]:0..<[1↓,0↓]:0"
      let doc1 = """
        root
        ├ paragraph
        └ paragraph
          ├ text "The "
          ├ emphasis
          │ └ text "quick brown "
          └ text "fox"
        """
      let range2 = "[0↓,0↓]:0"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {  // in the middle
      let documentManager = createDocumentManager()
      let range = {

        let path: [RohanIndex] = [
          .index(0),  // paragraph
          .index(0),  // text
        ]
        let location = TextLocation(path, "Th".count)
        return RhTextRange(location)
      }()

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[0↓,0↓]:2..<[1↓,0↓]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "Th"
        └ paragraph
          ├ text "e "
          ├ emphasis
          │ └ text "quick brown "
          └ text "fox"
        """
      let range2 = "[0↓,0↓]:2"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {  // at the end
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(0),  // paragraph
          .index(0),  // text
        ]
        let location = TextLocation(path, "The ".count)
        return RhTextRange(location)
      }()

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[0↓,0↓]:4..<[1↓]:0"
      let doc1 = """
        root
        ├ paragraph
        │ └ text "The "
        └ paragraph
          ├ emphasis
          │ └ text "quick brown "
          └ text "fox"
        """
      let range2 = "[0↓,0↓]:4"

      testRoundTrip(
        range, nodes, documentManager,
        range1: range1, doc1: doc1, range2: range2)
    }

    do {  // at paragraph end
      let documentManager = createDocumentManager()
      let range = {
        let path: [RohanIndex] = [
          .index(0),  // paragraph
          .index(2),  // text
        ]
        let location = TextLocation(path, "fox".count)
        return RhTextRange(location)
      }()

      let nodes = documentManager.resolveInsertParagraphBreak(at: range)

      let range1 = "[0↓,2↓]:3..<[1↓]:0"
      let doc1 = """
        root
        ├ paragraph
        │ ├ text "The "
        │ ├ emphasis
        │ │ └ text "quick brown "
        │ └ text "fox"
        └ paragraph
        """
      let range2 = "[0↓,2↓]:3"

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
            EmphasisNode([TextNode("quick brown ")]),
            TextNode("fox"),
          ])
      ])
      return createDocumentManager(rootNode)
    }()

    let range = {
      let path: [RohanIndex] = [
        .index(0),  // heading
        .index(1),  // emphasis
        .index(0),  // text
      ]
      let location = TextLocation(path, "quick ".count)
      return RhTextRange(location)
    }()

    let nodes = documentManager.resolveInsertParagraphBreak(at: range)
    let result = documentManager.replaceContents(in: range, with: nodes)
    #expect(result.isFailure)
  }
}
