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
      documentView.styleSheet = StyleSheets.testingRecord.provider(12)
    }
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("Heading")]),
        ParagraphNode([TextNode("This is a paragraph.")]),
      ])
      documentView.setContent(DocumentContent(rootNode))
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
  func deletePlus() {
    let documentView = DocumentView()
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("HelloW")])
      ])
      documentView.setContent(DocumentContent(rootNode))
    }
    let documentManager = documentView.documentManager
    do {
      let location = TextLocation.parse("[↓0,↓0]:5")!
      documentManager.textSelection = RhTextSelection(location)
    }

    do {
      documentView.deleteBackward(nil)
      let expected =
        """
        root
        └ heading
          └ text "HellW"
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    do {
      documentView.deleteForward(nil)
      let expected =
        """
        root
        └ heading
          └ text "Hell"
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    do {
      documentView.deleteWordBackward(nil)
      let expected =
        """
        root
        └ heading
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    do {
      documentView.deleteBackward(nil)
      let expected =
        """
        root
        └ heading
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    do {
      documentView.deleteBackward(nil)
      let expected =
        """
        root
        └ paragraph
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    do {
      documentView.deleteForward(nil)
      let expected =
        """
        root
        └ paragraph
        """
      #expect(documentManager.prettyPrint() == expected)
    }
  }

  /// copy(), paste(), cut(), delete()
  @Test
  func copyPaste() {
    let documentView = DocumentView()
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("HelloW")]),
        ParagraphNode([TextNode("Hellorld")]),
      ])
      documentView.setContent(DocumentContent(rootNode))
    }
    let documentManager = documentView.documentManager
    do {
      let range = RhTextRange.parse("[↓1,↓0]:4..<[↓1,↓0]:8")!
      documentManager.textSelection = RhTextSelection(range)
    }
    do {
      documentView.copy(nil)
      let location = TextLocation.parse("[↓0,↓0]:6")!
      documentManager.textSelection = RhTextSelection(location)
      documentView.paste(nil)

      let expected =
        """
        root
        ├ heading
        │ └ text "HelloWorld"
        └ paragraph
          └ text "Hellorld"
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    do {
      let range = RhTextRange.parse("[↓1,↓0]:5..<[↓1,↓0]:8")!
      documentManager.textSelection = RhTextSelection(range)
      documentView.cut(nil)
      let expected =
        """
        root
        ├ heading
        │ └ text "HelloWorld"
        └ paragraph
          └ text "Hello"
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    do {
      documentView.paste(nil)
      let expected =
        """
        root
        ├ heading
        │ └ text "HelloWorld"
        └ paragraph
          └ text "Hellorld"
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    do {
      let range = RhTextRange.parse("[↓1,↓0]:5..<[↓1,↓0]:8")!
      documentManager.textSelection = RhTextSelection(range)
      documentView.delete(nil)
      let expected =
        """
        root
        ├ heading
        │ └ text "HelloWorld"
        └ paragraph
          └ text "Hello"
        """
      #expect(documentManager.prettyPrint() == expected)
    }

    // paste without success but no error
    do {
      let range = RhTextRange.parse("[]:0..<[]:1")!
      documentManager.textSelection = RhTextSelection(range)
      documentView.copy(nil)

      let location = RhTextRange.parse("[↓0,↓0]:6")!
      documentManager.textSelection = RhTextSelection(location)
      documentView.paste(nil)

      let expected =
        """
        root
        ├ heading
        │ └ text "HelloWorld"
        └ paragraph
          └ text "Hello"
        """
      #expect(documentManager.prettyPrint() == expected)
    }
  }

  @Test
  func undoRedo() {
    let documentView = DocumentView()
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("The quick brown fox")])
      ])
      documentView.setContent(DocumentContent(rootNode))
    }
    let documentManager = documentView.documentManager
    let expected0 =
      """
      root
      └ heading
        └ text "The quick brown fox"
      """
    let expected1 =
      """
      root
      └ heading
        └ text "The  brown fox"
      """

    do {
      let range = RhTextRange.parse("[↓0,↓0]:4..<[↓0,↓0]:9")!
      documentManager.textSelection = RhTextSelection(range)
      documentView.deleteBackward(nil)
      #expect(documentManager.prettyPrint() == expected1)
    }
    documentView.undo(nil)
    #expect(documentManager.prettyPrint() == expected0)
    documentView.undo(nil)
    #expect(documentManager.prettyPrint() == expected0)
    documentView.redo(nil)
    #expect(documentManager.prettyPrint() == expected1)
    documentView.redo(nil)
    #expect(documentManager.prettyPrint() == expected1)
  }

  @Test
  func magnify() {
    let scrollView = NSScrollView()
    let documentView = DocumentView()
    scrollView.documentView = documentView
    scrollView.magnification = 2.0
    documentView.scrollView(scrollView, didChangeMagnification: ())
  }

  @Test
  func navigate() {
    let documentView = DocumentView()
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("The quick brown fox")]),
        ParagraphNode([TextNode("jumps over the lazy dog.")]),
      ])
      documentView.setContent(DocumentContent(rootNode))
    }

    let documentManager = documentView.documentManager

    // set selection
    func gotoLocation1() {
      let location = TextLocation.parse("[↓0,↓0]:7")!
      documentManager.textSelection = RhTextSelection(location)
    }
    func gotoLocation2() {
      let location = TextLocation.parse("[↓1,↓0]:8")!
      documentManager.textSelection = RhTextSelection(location)
    }

    // linear move
    do {
      gotoLocation1()
      documentView.moveForward(nil)
      let expected = "(location: [↓0,↓0]:8, affinity: upstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveBackward(nil)
      let expected = "(location: [↓0,↓0]:6, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveRight(nil)
      let expected = "(location: [↓0,↓0]:8, affinity: upstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveLeft(nil)
      let expected = "(location: [↓0,↓0]:6, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveRightAndModifySelection(nil)
      let expected =
        "(anchor: [↓0,↓0]:7, focus: [↓0,↓0]:8, reversed: false, affinity: upstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveLeftAndModifySelection(nil)
      let expected =
        "(anchor: [↓0,↓0]:7, focus: [↓0,↓0]:6, reversed: true, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }

    // move up/down
    do {
      gotoLocation1()
      documentView.moveDown(nil)
      let expected = "(location: [↓1,↓0]:10, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveDownAndModifySelection(nil)
      let expected =
        "(anchor: [↓0,↓0]:7, focus: [↓1,↓0]:10, reversed: false, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation2()
      documentView.moveUp(nil)
      let expected = "(location: [↓0,↓0]:5, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation2()
      documentView.moveUpAndModifySelection(nil)
      let expected =
        "(anchor: [↓1,↓0]:8, focus: [↓0,↓0]:5, reversed: true, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    
    // move word-wise
    do {
      gotoLocation1()
      documentView.moveWordRight(nil)
      let expected = "(location: [↓0,↓0]:10, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveWordLeft(nil)
      let expected = "(location: [↓0,↓0]:4, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveWordRightAndModifySelection(nil)
      let expected =
        "(anchor: [↓0,↓0]:7, focus: [↓0,↓0]:10, reversed: false, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
    do {
      gotoLocation1()
      documentView.moveWordLeftAndModifySelection(nil)
      let expected =
        "(anchor: [↓0,↓0]:7, focus: [↓0,↓0]:4, reversed: true, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)
    }
  }

  @Test
  func notification() {
    let documentView = DocumentView()
    documentView.notifyOperationRejected()
  }
}
