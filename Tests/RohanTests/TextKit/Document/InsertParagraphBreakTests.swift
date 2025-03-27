// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

final class InsertParagraphBreakTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: false)
  }

  func performAction(
    _ rootNode: RootNode, _ location: TextLocation
  ) -> (DocumentManager, TextLocation, Bool)? {
    let documentManager = createDocumentManager(rootNode)

    documentManager.beginEditing()
    let result = documentManager.insertParagraphBreak(at: RhTextRange(location))
    switch result {
    case .success(let range):
      documentManager.endEditing()
      return (documentManager, range.endLocation, true)
    case .failure(let error):
      documentManager.endEditing()
      if error.code == .ContentToInsertIsIncompatible {
        return (documentManager, location, false)
      }
      else {
        Issue.record("Failed to insert paragraph break at \(location)")
        return nil
      }
    }
  }

  @Test
  func test_EmptyRoot() throws {
    let rootNode = RootNode()
    let location = TextLocation([], 0)
    let (documentManager, newLocation, inserted) = performAction(rootNode, location)!
    #expect(inserted)
    #expect("\(newLocation)" == "[]:2")
    #expect(
      documentManager.prettyPrint() == """
        root
        ├ paragraph
        └ paragraph
        """)
  }

  @Test
  func test_Root() throws {
    func doTest(_ location: TextLocation) -> (DocumentManager, TextLocation, Bool)? {
      let rootNode = RootNode([
        ParagraphNode([TextNode("Hello")]),
        ParagraphNode([TextNode("World")]),
      ])
      return self.performAction(rootNode, location)
    }

    do {  // at the beginning
      let location = TextLocation([], 0)
      let (documentManager, newLocation, inserted) = doTest(location)!

      #expect(inserted)
      #expect("\(newLocation)" == "[1↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          ├ paragraph
          │ └ text "Hello"
          └ paragraph
            └ text "World"
          """)
    }
    do {
      let location = TextLocation([], 1)
      let (documentManager, newLocation, inserted) = doTest(location)!

      #expect(inserted)
      #expect("\(newLocation)" == "[2↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ └ text "Hello"
          ├ paragraph
          └ paragraph
            └ text "World"
          """)
    }
    do {
      let location = TextLocation([], 2)
      let (documentManager, newLocation, inserted) = doTest(location)!

      #expect(inserted)
      #expect("\(newLocation)" == "[]:4")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ └ text "Hello"
          ├ paragraph
          │ └ text "World"
          ├ paragraph
          └ paragraph
          """)
    }
  }

  @Test
  func test_Element() throws {
    func performAction(_ location: TextLocation) -> (DocumentManager, TextLocation, Bool)?
    {
      let rootNode = RootNode([
        ParagraphNode([TextNode("Abc")]),
        ParagraphNode(
          [
            TextNode("Hello, "),
            EmphasisNode([TextNode("world")]),
          ]),
        ParagraphNode([TextNode("Def")]),
      ])
      return self.performAction(rootNode, location)
    }

    do {
      let path: [RohanIndex] = [
        .index(1)  // heading
      ]
      let location = TextLocation(path, 0)
      let (documentManager, newLocation, inserted) = performAction(location)!
      #expect(inserted)
      #expect("\(newLocation)" == "[2↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
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
          """)
    }
    do {
      let path: [RohanIndex] = [
        .index(1)  // heading
      ]
      let location = TextLocation(path, 1)
      let (documentManager, newLocation, inserted) = performAction(location)!
      #expect(inserted)
      #expect("\(newLocation)" == "[2↓]:0")
      #expect(
        documentManager.prettyPrint() == """
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
          """)
    }

    do {
      let path: [RohanIndex] = [
        .index(1)  // heading
      ]
      let location = TextLocation(path, 2)
      let (documentManager, newLocation, inserted) = performAction(location)!
      #expect(inserted)
      #expect("\(newLocation)" == "[2↓]:0")
      #expect(
        documentManager.prettyPrint() == """
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
          """)
    }
  }

  @Test
  func test_Text() throws {
    func performAction(_ location: TextLocation) -> (DocumentManager, TextLocation, Bool)?
    {
      let rootNode = RootNode([
        ParagraphNode(
          [
            TextNode("The "),
            EmphasisNode([TextNode("quick brown ")]),
            TextNode("fox"),
          ])
      ])
      return self.performAction(rootNode, location)
    }

    do {  // at the beginning
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      let (documentManager, newLocation, inserted) = performAction(location)!
      #expect(inserted)
      #expect("\(newLocation)" == "[1↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          └ paragraph
            ├ text "The "
            ├ emphasis
            │ └ text "quick brown "
            └ text "fox"
          """)
    }

    do {  // in the middle
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, "Th".count)
      let (documentManager, newLocation, inserted) = performAction(location)!
      #expect(inserted)
      #expect("\(newLocation)" == "[1↓,0↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ └ text "Th"
          └ paragraph
            ├ text "e "
            ├ emphasis
            │ └ text "quick brown "
            └ text "fox"
          """)
    }

    do {  // at the end
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, "The ".count)
      let (documentManager, newLocation, inserted) = performAction(location)!
      #expect(inserted)
      #expect("\(newLocation)" == "[1↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ └ text "The "
          └ paragraph
            ├ emphasis
            │ └ text "quick brown "
            └ text "fox"
          """)
    }

    do {  // at paragraph end
      let path: [RohanIndex] = [
        .index(0),  // paragraph
        .index(2),  // text
      ]
      let location = TextLocation(path, "fox".count)
      let (documentManager, newLocation, inserted) = performAction(location)!
      #expect(inserted)
      #expect("\(newLocation)" == "[1↓]:0")
      #expect(
        documentManager.prettyPrint() == """
          root
          ├ paragraph
          │ ├ text "The "
          │ ├ emphasis
          │ │ └ text "quick brown "
          │ └ text "fox"
          └ paragraph
          """)
    }
  }

  @Test
  func test_Emphasis() throws {
    func performAction(_ location: TextLocation) -> (DocumentManager, TextLocation, Bool)?
    {
      let rootNode = RootNode([
        HeadingNode(
          level: 1,
          [
            TextNode("The "),
            EmphasisNode([TextNode("quick brown ")]),
            TextNode("fox"),
          ])
      ])
      return self.performAction(rootNode, location)
    }

    let path: [RohanIndex] = [
      .index(0),  // heading
      .index(1),  // emphasis
      .index(0),  // text
    ]
    let location = TextLocation(path, "quick ".count)

    let (documentManager, newLocation, inserted) = performAction(location)!
    #expect(inserted == false)
    #expect("\(newLocation)" == "[0↓,1↓,0↓]:6")
    #expect(
      documentManager.prettyPrint() == """
        root
        └ heading
          ├ text "The "
          ├ emphasis
          │ └ text "quick brown "
          └ text "fox"
        """)
  }
}
