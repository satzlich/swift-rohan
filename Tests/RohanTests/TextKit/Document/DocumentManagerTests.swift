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
