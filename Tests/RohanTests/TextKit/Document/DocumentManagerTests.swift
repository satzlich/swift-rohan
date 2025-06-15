// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

final class DocumentManagerTests {
  /// Helper function to create a `DocumentManager` instance with a given content.
  private func _createDocumentManager(_ content: ElementStore) -> DocumentManager {
    let rootNode = RootNode(content)
    let documentManager = DocumentManager(rootNode, StyleSheetTests.testingStyleSheet())
    return documentManager
  }

  // MARK: - IME Support

  private func _imeSupportExample() -> DocumentManager {
    let documentManager = _createDocumentManager([
      ParagraphNode([
        TextNode("Hello"),
        EmphasisNode([TextNode("a😀bc")]),
        TextNode("!"),
      ])
    ])
    return documentManager
  }

  @Test
  func location_llOffsetBy() {
    let documentManager = _imeSupportExample()
    do {
      let location = TextLocation.parse("[↓0,↓0]:0")!
      let result = documentManager.location(location, llOffsetBy: 3)
      #expect(result == TextLocation.parse("[↓0,↓0]:3"))
    }
  }

  @Test
  func attributedSubstring() {
    let documentManager = _imeSupportExample()
    do {
      let location = TextLocation.parse("[↓0,↓1,↓0]:1")!
      let end = TextLocation.parse("[↓0,↓1,↓0]:4")!
      let range = RhTextRange(location, end)!
      let result = documentManager.attributedSubstring(for: range)
      #expect(result?.string == "😀b")
    }
  }

  @Test
  func llOffset_from_to() {
    let documentManager = _imeSupportExample()
    let location = TextLocation.parse("[↓0,↓1,↓0]:1")!
    let end = TextLocation.parse("[↓0,↓1,↓0]:4")!
    do {
      let result = documentManager.llOffset(from: location, to: end)
      #expect(result == 3)
    }
    do {
      let result = documentManager.llOffset(from: end, to: location)
      #expect(result == -3)
    }
  }

  // MARK: - Replacement Support

  private func _replacementSupportExample() -> DocumentManager {
    let documentManager = _createDocumentManager([
      EquationNode(
        .block,
        [
          TextNode("xyzw"),
          NamedSymbolNode(NamedSymbol.lookup("alpha")!),
          TextNode("bc"),
          NamedSymbolNode(NamedSymbol.lookup("beta")!),
          NamedSymbolNode(NamedSymbol.lookup("iota")!),
          TextNode("jk"),
          FractionNode(num: [TextNode("a")], denom: [TextNode("b")]),
          TextNode("mn"),
        ])
    ])
    return documentManager
  }

  @Test
  func prefixString__traceBackward() {
    let documentManager = _replacementSupportExample()

    func makeReversed(_ extendedString: ExtendedString) -> ExtendedSubstring {
      ExtendedSubstring(extendedString.reversed())
    }

    // unexpected argument
    do {
      let location = TextLocation.parse("[↓0,nuc]:1")!
      let result = documentManager.prefixString(from: location, count: 2)
      #expect(result == nil)
    }
    // size larger than available range
    do {
      let location = TextLocation.parse("[↓0,nuc,↓0]:1")!
      let result = documentManager.prefixString(from: location, count: 2)
      let expected = ExtendedString([.char("x")])
      #expect(result == expected)

      let traceResult =
        documentManager.traceBackward(from: location, makeReversed(expected))
      guard let traceLocation = traceResult else {
        Issue.record("Trace backward failed")
        return
      }
      #expect("\(traceLocation)" == "[↓0,nuc,↓0]:0")
    }
    // cross non-text node
    do {
      let location = TextLocation.parse("[↓0,nuc,↓2]:1")!
      let result = documentManager.prefixString(from: location, count: 2)
      let expected = ExtendedString([.symbol(NamedSymbol.lookup("alpha")!), .char("b")])
      #expect(result == expected)

      let traceResult =
        documentManager.traceBackward(from: location, makeReversed(expected))
      guard let traceLocation = traceResult else {
        Issue.record("Trace backward failed")
        return
      }
      #expect("\(traceLocation)" == "[↓0,nuc]:1")
    }
    // cross non-text node, then text node
    do {
      let location = TextLocation.parse("[↓0,nuc,↓2]:1")!
      let result = documentManager.prefixString(from: location, count: 3)
      let expected =
        ExtendedString([.char("w"), .symbol(NamedSymbol.lookup("alpha")!), .char("b")])
      #expect(result == expected)

      let traceResult =
        documentManager.traceBackward(from: location, makeReversed(expected))
      guard let traceLocation = traceResult else {
        Issue.record("Trace backward failed")
        return
      }
      #expect("\(traceLocation)" == "[↓0,nuc,↓0]:3")
    }
    // cross non-text node, then text node, then non-text node
    do {
      let location = TextLocation.parse("[↓0,nuc,↓5]:1")!
      let result = documentManager.prefixString(from: location, count: 7)
      let expected =
        ExtendedString([
          .char("w"),
          .symbol(NamedSymbol.lookup("alpha")!),
          .char("b"),
          .char("c"),
          .symbol(NamedSymbol.lookup("beta")!),
          .symbol(NamedSymbol.lookup("iota")!),
          .char("j"),
        ])
      #expect(result == expected)

      let traceResult =
        documentManager.traceBackward(from: location, makeReversed(expected))
      guard let traceLocation = traceResult else {
        Issue.record("Trace backward failed")
        return
      }
      #expect("\(traceLocation)" == "[↓0,nuc,↓0]:3")
    }
    // meet unsupported node and stop
    do {
      let location = TextLocation.parse("[↓0,nuc,↓7]:1")!
      let result = documentManager.prefixString(from: location, count: 6)
      let expected = ExtendedString([.char("m")])
      #expect(result == expected)

      let traceResult =
        documentManager.traceBackward(from: location, makeReversed(expected))
      guard let traceLocation = traceResult else {
        Issue.record("Trace backward failed")
        return
      }
      #expect("\(traceLocation)" == "[↓0,nuc,↓7]:0")
    }
  }

  // MARK: - Location Query

  @Test
  func getNode() {
    let documentManager = _createDocumentManager([
      ParagraphNode([
        EmphasisNode([TextNode("Hello")])
      ])
    ])

    // character of a text node
    do {
      let location = TextLocation.parse("[↓0,↓0,↓0]:0")!
      let node0 = documentManager.getNode(at: location)
      #expect(node0 == nil)
      let node1 = documentManager.getNode(at: location.asArray)
      #expect(node1 == nil)
    }

    // text node
    do {
      let location = TextLocation.parse("[↓0,↓0]:0")!
      let node0 = documentManager.getNode(at: location)
      #expect(node0 is TextNode)
      let node1 = documentManager.getNode(at: location.asArray)
      #expect(node1 is TextNode)
    }
  }

  @Test
  func crossedObjectAt() {

    let documentManager = _createDocumentManager([
      HeadingNode(level: 1, [TextNode("Hello")]),
      EquationNode(.block, [FractionNode(num: [], denom: [])]),
    ])

    // location points to the interior of text node.
    do {
      let location = TextLocation.parse("[↓0,↓0]:2")!
      let result0 = documentManager.crossedObjectAt(location, direction: .forward)
      #expect(result0?.text()?.string == "l")
      let result1 = documentManager.crossedObjectAt(location, direction: .backward)
      #expect(result1?.text()?.string == "e")
    }
    // location points to the edges of a text node
    do {
      let location0 = TextLocation.parse("[↓0,↓0]:0")!
      let result0 = documentManager.crossedObjectAt(location0, direction: .backward)
      #expect(result0?.isBlockBoundary == true)

      let location1 = TextLocation.parse("[↓0,↓0]:5")!
      let result1 = documentManager.crossedObjectAt(location1, direction: .forward)
      #expect(result1?.isBlockBoundary == true)
    }

    // location points to a node which is a text node
    do {
      let location = TextLocation.parse("[↓0]:0")!
      let result0 = documentManager.crossedObjectAt(location, direction: .forward)
      #expect(result0?.text()?.string == "H")
    }
    // location points to a node whose predecessor is a text node
    do {
      let location = TextLocation.parse("[↓0]:1")!
      let result = documentManager.crossedObjectAt(location, direction: .backward)
      #expect(result?.text()?.string == "o")
    }
    // (a) location points to a non-text node whose predecessor is non-existent
    //     and the node itself is non-block.
    do {
      let location = TextLocation.parse("[↓1,nuc]:0")!
      let result0 = documentManager.crossedObjectAt(location, direction: .backward)
      #expect(result0 == nil)
      let result1 = documentManager.crossedObjectAt(location, direction: .forward)
      #expect(result1?.nonTextNode()?.node is FractionNode)
    }
    // (b) location points to a non-text node whose successor is non-existent
    //     and the node itself is non-block.
    do {
      let location = TextLocation.parse("[↓1,nuc]:1")!
      let result0 = documentManager.crossedObjectAt(location, direction: .backward)
      #expect(result0?.nonTextNode()?.node is FractionNode)
      let result1 = documentManager.crossedObjectAt(location, direction: .forward)
      #expect(result1 == nil)
    }
  }

  @Test
  func descendTo() {
    let documentManager = _createDocumentManager([
      EquationNode(
        .block,
        [
          AttachNode(nuc: [], sup: [TextNode("abc")]),
          MatrixNode(
            .pmatrix,
            [
              MatrixNode.Row([
                ContentNode([TextNode("1")]),
                ContentNode([TextNode("2")]),
              ]),
              MatrixNode.Row([
                ContentNode([TextNode("3")]),
                ContentNode([TextNode("4")]),
              ]),
            ]),
        ])
    ])

    // descend into MathNode
    do {
      let location = TextLocation.parse("[↓0,nuc]:0")!
      let target = documentManager.descendTo(location, .Left(.sup))
      #expect(target != nil)
      #expect("\(target!)" == "[↓0,nuc,↓0,sup,↓0]:3")
    }
    // descend into MatrixNode
    do {
      let location = TextLocation.parse("[↓0,nuc]:1")!
      let gridIndex = GridIndex(0, 1)
      let target = documentManager.descendTo(location, .Right(gridIndex))
      #expect(target != nil)
      #expect("\(target!)" == "[↓0,nuc,↓1,(0,1),↓0]:1")
    }
  }

  @Test
  func contextualNode() {
    let documentManager = _createDocumentManager([
      EquationNode(
        .block,
        [
          FractionNode(num: [TextNode("x")], denom: [TextNode("y")])
        ])
    ])

    do {
      let location = TextLocation.parse("[↓0,nuc,↓0,num,↓0]:1")!
      let result = documentManager.contextualNode(for: location)
      #expect(result?.node is FractionNode)
    }
  }
}
