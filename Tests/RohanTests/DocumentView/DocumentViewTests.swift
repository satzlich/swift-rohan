// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

@MainActor
struct DocumentViewTests {
  private static func bakedDocumentView() -> DocumentView {
    let documentView = DocumentView()

    // set up completion provider
    let completionProvider = CompletionProvider()
    completionProvider.addItems(CommandRecords.allCases)
    documentView.completionProvider = completionProvider
    // set up replacement engine
    let replacementProvider = ReplacementProvider(ReplacementRules.allCases)
    documentView.replacementProvider = replacementProvider

    return documentView
  }

  @Test
  func basic() {
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
    do {
      documentView.forceUpdate(selection: true, scroll: true)
    }
  }

  @Test
  func insert() {
    let documentView = DocumentView()
    let documentManager = documentView.documentManager
    let selection =
      RhTextSelection(documentManager.documentRange.location, affinity: .downstream)
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
      documentManager.textSelection = RhTextSelection(location, affinity: .downstream)
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

    func setPasteboard(_ text: String) {
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      let success = pasteboard.setString(text, forType: .string)
      #expect(success == true, "Failed to set string on pasteboard: \(text)")
    }
    func setSelection(_ range: RhTextRange) {
      documentManager.textSelection = RhTextSelection(range, affinity: .downstream)
    }

    setSelection(RhTextRange.parse("[↓1,↓0]:4..<[↓1,↓0]:8")!)
    do {
      documentView.copy(nil)
      setSelection(RhTextRange.parse("[↓0,↓0]:6")!)
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
      setSelection(RhTextRange.parse("[↓1,↓0]:5..<[↓1,↓0]:8")!)
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
      setSelection(RhTextRange.parse("[↓1,↓0]:5..<[↓1,↓0]:8")!)
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
      setSelection(RhTextRange.parse("[]:0..<[]:1")!)
      documentView.copy(nil)
      setSelection(RhTextRange.parse("[↓0,↓0]:6")!)
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

    // paste from external source
    do {
      // prepare the pasteboard
      let textToCopy = "veni. vidi. vici."
      setPasteboard(textToCopy)
      // set selection
      setSelection(RhTextRange.parse("[↓1,↓0]:0..<[↓1,↓0]:5")!)
      // paste
      documentView.paste(nil)
      let expected =
        """
        root
        ├ heading
        │ └ text "HelloWorld"
        └ paragraph
          └ text "veni. vidi. vici."
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    // paste from external source that contains newline
    do {
      // prepare the pasteboard
      setPasteboard("abc\n\nxyz")
      // set selection
      setSelection(RhTextRange.parse("[↓1,↓0]:6..<[↓1,↓0]:11")!)
      // paste
      documentView.paste(nil)
      let expected =
        """
        root
        ├ heading
        │ └ text "HelloWorld"
        ├ paragraph
        │ └ text "veni. abc"
        ├ paragraph
        └ paragraph
          └ text "xyz vici."
        """
      #expect(documentManager.prettyPrint() == expected)

      // paste again in heading
      setSelection(RhTextRange.parse("[↓0,↓0]:1..<[↓0,↓0]:3")!)
      documentView.paste(nil)
      // no change expected
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
      documentManager.textSelection = RhTextSelection(range, affinity: .downstream)
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
      documentManager.textSelection = RhTextSelection(location, affinity: .downstream)
    }
    func gotoLocation2() {
      let location = TextLocation.parse("[↓1,↓0]:8")!
      documentManager.textSelection = RhTextSelection(location, affinity: .downstream)
    }

    // select all
    do {
      documentView.selectAll(nil)
      let expected =
        "(anchor: []:0, focus: [↓1,↓0]:24, reversed: false, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected)

      documentView.moveForward(nil)
      let expected2 = "(location: [↓1,↓0]:24, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected2)

      documentView.selectAll(nil)
      let expected3 = expected
      #expect("\(documentManager.textSelection!)" == expected3)

      documentView.moveBackward(nil)
      let expected4 = "(location: []:0, affinity: downstream)"
      #expect("\(documentManager.textSelection!)" == expected4)
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
  func replacementRule() {
    // for this test case, we need the "baked" DocumentView.
    let documentView = Self.bakedDocumentView()
    do {
      let rootNode = RootNode([
        HeadingNode(level: 1, [TextNode("text ..")]),
        EquationNode(
          .block,
          [
            TextNode("frac")
          ]),
      ])
      documentView.setContent(DocumentContent(rootNode))
    }

    let documentManager = documentView.documentManager
    // trigger "..." -> "…"
    do {
      let location = TextLocation.parse("[↓0,↓0]:7")!
      documentManager.textSelection = RhTextSelection(location, affinity: .downstream)
      documentView.insertText(".", replacementRange: .notFound)

      let expected = """
        root
        ├ heading
        │ └ text "text …"
        └ equation
          └ nuc
            └ text "frac"
        """
      #expect(documentManager.prettyPrint() == expected)
    }
    // trigger "frac " -> FractionNode
    do {
      let location = TextLocation.parse("[↓1,nuc,↓0]:4")!
      documentManager.textSelection = RhTextSelection(location, affinity: .downstream)
      documentView.insertText(" ", replacementRange: .notFound)

      let expected = """
        root
        ├ heading
        │ └ text "text …"
        └ equation
          └ nuc
            └ fraction
              ├ num
              └ denom
        """
      #expect(documentManager.prettyPrint() == expected)
      #expect(documentManager.textSelection != nil)
      #expect(
        "\(documentManager.textSelection!)"
          == "(location: [↓1,nuc,↓0,num]:0, affinity: downstream)")
    }
  }

  @Test
  func moreReplacementRule() {  // match string and named symbols
    // for this test case, we need the "baked" DocumentView.
    let documentView = Self.bakedDocumentView()
    do {
      let rootNode = RootNode([
        EquationNode(
          .block,
          [
            NamedSymbolNode(NamedSymbol.lookup("lvert")!),
            TextNode(".+"),
          ])
      ])
      documentView.setContent(DocumentContent(rootNode))
    }
    let documentManager = documentView.documentManager
    do {
      let location = TextLocation.parse("[↓0,nuc,↓1]:1")!
      documentManager.textSelection = RhTextSelection(location, affinity: .downstream)
      documentView.insertText(" ", replacementRange: .notFound)

      let expected = """
        root
        └ equation
          └ nuc
            ├ leftRight
            │ └ nuc
            └ text "+"
        """
      #expect(documentManager.prettyPrint() == expected)
      #expect(documentManager.textSelection != nil)
      #expect(
        "\(documentManager.textSelection!)"
          == "(location: [↓0,nuc,↓0,nuc]:0, affinity: downstream)")
    }
  }

  @Test
  func editMath_AttachNode() {
    let documentView = DocumentView()
    do {
      let rootNode = RootNode([
        EquationNode(
          .block,
          [
            AttachNode(
              nuc: [TextNode("a")], lsub: [TextNode("b")], lsup: [TextNode("c")])
          ])
      ])
      documentView.setContent(DocumentContent(rootNode))
    }

    func gotoLocation(_ location: TextLocation) {
      let documentManager = documentView.documentManager
      documentManager.textSelection = RhTextSelection(location, affinity: .downstream)
    }

    let documentManager = documentView.documentManager
    let nucleusLocation = TextLocation.parse("[↓0,nuc,↓0,nuc,↓0]:1")!
    // remove lsub
    do {
      gotoLocation(nucleusLocation)
      documentView.removeLeftSubscript(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ attach
              ├ lsup
              │ └ text "c"
              └ nuc
                └ text "a"
        """
      let selection1 = "(location: [↓0,nuc]:1, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
    // add sub
    do {
      gotoLocation(nucleusLocation)
      documentView.addSubscript(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ attach
              ├ lsup
              │ └ text "c"
              ├ nuc
              │ └ text "a"
              └ sub
        """
      let selection1 = "(location: [↓0,nuc,↓0,sub]:0, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
    // remove lsup
    do {
      gotoLocation(nucleusLocation)
      documentView.removeLeftSuperscript(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ attach
              ├ nuc
              │ └ text "a"
              └ sub
        """
      let selection1 = "(location: [↓0,nuc]:1, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
    // add sup
    do {
      gotoLocation(nucleusLocation)
      documentView.addSuperscript(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ attach
              ├ nuc
              │ └ text "a"
              ├ sub
              └ sup
        """
      let selection1 = "(location: [↓0,nuc,↓0,sup]:0, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
    // remove sub
    do {
      gotoLocation(nucleusLocation)
      documentView.removeSubscript(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ attach
              ├ nuc
              │ └ text "a"
              └ sup
        """
      let selection1 = "(location: [↓0,nuc]:1, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
    // add lsub
    do {
      gotoLocation(nucleusLocation)
      documentView.addLeftSubscript(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ attach
              ├ lsub
              ├ nuc
              │ └ text "a"
              └ sup
        """
      let selection1 = "(location: [↓0,nuc,↓0,lsub]:0, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
    // remove sup
    do {
      gotoLocation(nucleusLocation)
      documentView.removeSuperscript(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ attach
              ├ lsub
              └ nuc
                └ text "a"
        """
      let selection1 = "(location: [↓0,nuc]:1, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
    // add lsup
    do {
      gotoLocation(nucleusLocation)
      documentView.addLeftSuperscript(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ attach
              ├ lsub
              ├ lsup
              └ nuc
                └ text "a"
        """
      let selection1 = "(location: [↓0,nuc,↓0,lsup]:0, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
  }
  
  
  @Test
  func editMath_RadicalNode() {
    let documentView = DocumentView()
    do {
      let rootNode = RootNode([
        EquationNode(
          .block,
          [
            RadicalNode([TextNode("a")], index: [TextNode("b")])
          ])
      ])
      documentView.setContent(DocumentContent(rootNode))
    }
    
    func gotoLocation(_ location: TextLocation) {
      let documentManager = documentView.documentManager
      documentManager.textSelection = RhTextSelection(location, affinity: .downstream)
    }
    
    let documentManager = documentView.documentManager
    let nucleusLocation = TextLocation.parse("[↓0,nuc,↓0,radicand,↓0]:1")!
    
    // remove index
    do {
      gotoLocation(nucleusLocation)
      documentView.removeDegree(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ radical
              └ radicand
                └ text "a"
        """
      let selection1 = "(location: [↓0,nuc]:1, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
    // add index
    do {
      gotoLocation(nucleusLocation)
      documentView.addDegree(nil)
      let expected1 = """
        root
        └ equation
          └ nuc
            └ radical
              ├ index
              └ radicand
                └ text "a"
        """
      let selection1 = "(location: [↓0,nuc,↓0,index]:0, affinity: upstream)"
      #expect(documentManager.prettyPrint() == expected1)
      #expect("\(documentManager.textSelection!)" == selection1)
    }
  }
}
