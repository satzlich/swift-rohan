// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

final class DocumentManagerTests: TextKitTestsBase {
  private func _createDocumentManager(_ nodes: ElementStore) -> DocumentManager {
    let rootNode = RootNode(nodes)
    return self.createDocumentManager(rootNode)
  }

  // MARK: - Edit Math

  /// cover the following methods:
  /// ```
  /// attachOrGotoMathComponent()
  /// removeMathComponent()
  /// ```
  @Test
  func editAttachNode_modifyExisting() {
    // create an example that contains AttachNode, RadicalNode, and MatrixNode
    let documentManager = _createDocumentManager([
      EquationNode(.block, [AttachNode(nuc: [TextNode("x")], sup: [TextNode("y")])])
    ])

    do {
      // attach sub to the first AttachNode
      let range = RhTextRange.parse("[↓0,nuc]:0..<[↓0,nuc]:1")!
      let result1 =
        documentManager.attachOrGotoMathComponent(range, .sub, [TextNode("a")])
      guard let (range1, isAdded) = result1.success() else {
        Issue.record("Attach or goto math component failed")
        return
      }
      #expect(isAdded)
      #expect("\(range1)" == "[↓0,nuc]:0..<[↓0,nuc]:1")

      let expected1 =
        """
        root
        └ equation
          └ nuc
            └ attach
              ├ nuc
              │ └ text "x"
              ├ sub
              │ └ text "a"
              └ sup
                └ text "y"
        """
      #expect(documentManager.prettyPrint() == expected1)

      // remove sub from the first AttachNode
      let result2 = documentManager.removeMathComponent(range1, .sub)
      guard let range2 = result2.success() else {
        Issue.record("Remove math component failed")
        return
      }
      let expected2 =
        """
        root
        └ equation
          └ nuc
            └ attach
              ├ nuc
              │ └ text "x"
              └ sup
                └ text "y"
        """
      #expect("\(range2)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
      #expect(documentManager.prettyPrint() == expected2)

      // goto sup of the first AttachNode
      let result3 = documentManager.attachOrGotoMathComponent(range2, .sup, [])
      guard let (range3, isAdded) = result3.success() else {
        Issue.record("Attach or goto math component failed")
        return
      }
      #expect(isAdded == false)
      #expect("\(range3)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
      let expected3 = expected2
      #expect(documentManager.prettyPrint() == expected3)

      // remove sup from the first AttachNode
      let result4 = documentManager.removeMathComponent(range3, .sup)
      guard let range4 = result4.success() else {
        Issue.record("Remove math component failed")
        return
      }
      #expect("\(range4)" == "[↓0,nuc,↓0]:0..<[↓0,nuc,↓0]:1")
      let expected4 =
        """
        root
        └ equation
          └ nuc
            └ text "x"
        """
      #expect(documentManager.prettyPrint() == expected4)
    }
  }

  /// cover the following methods:
  /// ```
  /// attachOrGotoMathComponent()
  /// removeMathComponent()
  /// ```
  @Test
  func editAttachNode_createNew() {
    let documentManager = _createDocumentManager([
      EquationNode(
        .block,
        [
          NamedSymbolNode(NamedSymbol.lookup("alpha")!),
          NamedSymbolNode(NamedSymbol.lookup("beta")!),
        ])
    ])

    do {
      let range = RhTextRange.parse("[↓0,nuc]:0..<[↓0,nuc]:1")!
      let result1 =
        documentManager.attachOrGotoMathComponent(range, .sub, [TextNode("c")])
      guard let (range1, isAdded) = result1.success() else {
        Issue.record("Attach or goto math component failed")
        return
      }
      #expect(isAdded)
      #expect("\(range1)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
      let expected1 =
        """
        root
        └ equation
          └ nuc
            ├ attach
            │ ├ nuc
            │ │ └ namedSymbol alpha
            │ └ sub
            │   └ text "c"
            └ namedSymbol beta
        """
      #expect(documentManager.prettyPrint() == expected1)
    }
    do {
      let range = RhTextRange.parse("[↓0,nuc]:1..<[↓0,nuc]:2")!
      let result1 =
        documentManager.attachOrGotoMathComponent(range, .sup, [TextNode("d")])
      guard let (range1, isAdded) = result1.success() else {
        Issue.record("Attach or goto math component failed")
        return
      }
      #expect(isAdded)
      #expect("\(range1)" == "[↓0,nuc]:1..<[↓0,nuc]:2")
      let expected1 =
        """
        root
        └ equation
          └ nuc
            ├ attach
            │ ├ nuc
            │ │ └ namedSymbol alpha
            │ └ sub
            │   └ text "c"
            └ attach
              ├ nuc
              │ └ namedSymbol beta
              └ sup
                └ text "d"
        """
      #expect(documentManager.prettyPrint() == expected1)
    }
  }

  @Test
  func editRadicalNode() {
    let documentManager = _createDocumentManager([
      EquationNode(
        .block,
        [
          RadicalNode([TextNode("x")], index: nil)
        ])
    ])

    let range = RhTextRange.parse("[↓0,nuc]:0..<[↓0,nuc]:1")!
    // attach index to the first RadicalNode
    let result1 =
      documentManager.attachOrGotoMathComponent(range, .index, [TextNode("n")])
    guard let (range1, isAdded) = result1.success() else {
      Issue.record("Attach or goto math component failed")
      return
    }
    #expect(isAdded)
    #expect("\(range1)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
    let expected1 =
      """
      root
      └ equation
        └ nuc
          └ radical
            ├ index
            │ └ text "n"
            └ radicand
              └ text "x"
      """
    #expect(documentManager.prettyPrint() == expected1)

    // remove index from the first RadicalNode
    let result2 = documentManager.removeMathComponent(range1, .index)
    guard let range2 = result2.success() else {
      Issue.record("Remove math component failed")
      return
    }
    #expect("\(range2)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
    let expected2 =
      """
      root
      └ equation
        └ nuc
          └ radical
            └ radicand
              └ text "x"
      """
    #expect(documentManager.prettyPrint() == expected2)
  }

  @Test
  func modifyGrid() {
    let documentManager = _createDocumentManager([
      EquationNode(
        .block,
        [
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
            ])
        ])
    ])

    let range = RhTextRange.parse("[↓0,nuc]:0..<[↓0,nuc]:1")!
    // add a new row
    let result1 =
      documentManager.modifyGrid(range, .insertRow([[], [TextNode("a")]], at: 1))
    guard let range1 = result1.success() else {
      Issue.record("Modify grid failed")
      return
    }
    #expect("\(range1)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
    let expected1 =
      """
      root
      └ equation
        └ nuc
          └ matrix
            ├ row 0
            │ ├ #0
            │ │ └ text "1"
            │ └ #1
            │   └ text "2"
            ├ row 1
            │ ├ #0
            │ └ #1
            │   └ text "a"
            └ row 2
              ├ #0
              │ └ text "3"
              └ #1
                └ text "4"
      """
    #expect(documentManager.prettyPrint() == expected1)
    // remove the added row
    let result2 = documentManager.modifyGrid(range1, .removeRow(at: 1))
    guard let range2 = result2.success() else {
      Issue.record("Modify grid failed")
      return
    }
    #expect("\(range2)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
    let expected2 =
      """
      root
      └ equation
        └ nuc
          └ matrix
            ├ row 0
            │ ├ #0
            │ │ └ text "1"
            │ └ #1
            │   └ text "2"
            └ row 1
              ├ #0
              │ └ text "3"
              └ #1
                └ text "4"
      """
    #expect(documentManager.prettyPrint() == expected2)

    // add a new column
    let result3 =
      documentManager.modifyGrid(range, .insertColumn([[], [TextNode("b")]], at: 1))
    guard let range3 = result3.success() else {
      Issue.record("Modify grid failed")
      return
    }
    #expect("\(range3)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
    let expected3 =
      """
      root
      └ equation
        └ nuc
          └ matrix
            ├ row 0
            │ ├ #0
            │ │ └ text "1"
            │ ├ #1
            │ └ #2
            │   └ text "2"
            └ row 1
              ├ #0
              │ └ text "3"
              ├ #1
              │ └ text "b"
              └ #2
                └ text "4"
      """
    #expect(documentManager.prettyPrint() == expected3)

    // remove the added column
    let result4 = documentManager.modifyGrid(range3, .removeColumn(at: 1))
    guard let range4 = result4.success() else {
      Issue.record("Modify grid failed")
      return
    }
    let expected4 = expected2
    #expect("\(range4)" == "[↓0,nuc]:0..<[↓0,nuc]:1")
    #expect(documentManager.prettyPrint() == expected4)
  }

  // MARK: - Navigation

  @Test
  func enclosingTextRange() {
    let documentManager = _createDocumentManager([
      ParagraphNode([
        TextNode("Mary has a little lamb")
      ])
    ])

    func composeLocation(_ offset: Int) -> TextLocation {
      TextLocation.parse("[↓0,↓0]:\(offset)")!
    }

    do {
      let offset = "Mary has a li".length
      let location = composeLocation(offset)
      let range = documentManager.enclosingTextRange(for: .word, location)
      guard let range = range else {
        Issue.record("Enclosing text range failed")
        return
      }
      #expect("\(range)" == "[↓0,↓0]:11..<[↓0,↓0]:18")  // "little "
    }
    do {
      let offeset = "Mary has a ".length
      let location = composeLocation(offeset)
      let range = documentManager.enclosingTextRange(for: .word, location)
      guard let range = range else {
        Issue.record("Enclosing text range failed")
        return
      }
      #expect("\(range)" == "[↓0,↓0]:11..<[↓0,↓0]:18")  // "little "
    }
    do {
      let offeset = "Mary has a".length
      let location = composeLocation(offeset)
      let range = documentManager.enclosingTextRange(for: .word, location)
      guard let range = range else {
        Issue.record("Enclosing text range failed")
        return
      }
      #expect("\(range)" == "[↓0,↓0]:9..<[↓0,↓0]:11")  // "a "
    }
  }

  // MARK: - IME Support

  private func _imeSupportExample() -> DocumentManager {
    let documentManager = _createDocumentManager([
      ParagraphNode([
        TextNode("Hello"),
        StrongNode(.emph, [TextNode("a😀bc")]),
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
        StrongNode(.emph, [TextNode("Hello")])
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

  // MARK: - SegmentFrame

  @Test
  func primaryInsertionIndicatorFrame() {
    let documentManager = _createDocumentManager([
      ParagraphNode([
        TextNode("Hello")
      ]),
      ParagraphNode([
        TextNode("World")
      ]),
    ])
    documentManager.reconcileLayout(scope: .document)

    let location = TextLocation.parse("[↓1,↓0]:0")!
    let frame =
      documentManager.primaryInsertionIndicatorFrame(at: location, .downstream)
    #expect(frame != nil)
    #expect("\(frame!)" == "(5.0, 17.0, 0.0, 17.0)")
  }
}
