// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

@MainActor
struct DocumentViewTests {
  @Test
  func main() {
    let scrollView = NSScrollView()
    let documentView = DocumentView()
    scrollView.documentView = documentView

    #expect(documentView.scrollView != nil)
    #expect(documentView.acceptsFirstResponder == true)
    do {
      documentView.layout()
      documentView.prepareContent(in: NSRect(x: 0, y: 0, width: 100, height: 100))
    }
    do {
      _ = documentView.styleSheet
      documentView.styleSheet = StyleSheets.stixTwo(FontSize(12))
    }
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("Heading")]),
        ParagraphNode([TextNode("This is a paragraph.")]),
      ])
      documentView.content = DocumentContent(rootNode)
    }
  }

  @Test
  func insert() {
    let documentView = DocumentView()
    let documentManager = documentView.documentManager
    let selection = RhTextSelection(documentManager.documentRange.location)
    documentManager.textSelection = selection

    do {
      documentView.insertText("Hello, World!")
      documentView.insertTab(nil)
      documentView.insertNewline(nil)
      let expected =
        """
        root
        ├ paragraph
        │ └ text "Hello, World!\t"
        └ paragraph
        """
      #expect(documentManager.prettyPrint() == expected)
    }

    do {
      documentView.insertText("Mary had a little lamb.")
      for _ in 0..<"lamb.".count {
        documentView.moveBackward(nil)
      }
      documentView.insertLineBreak(nil)
      let expected =
        """
        root
        ├ paragraph
        │ └ text "Hello, World!\t"
        └ paragraph
          ├ text "Mary had a little "
          ├ linebreak
          └ text "lamb."
        """
      #expect(documentManager.prettyPrint() == expected)
    }
  }

  @Test
  func notification() {
    let documentView = DocumentView()
    documentView.notifyOperationRejected()
  }
}
