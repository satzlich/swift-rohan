// Copyright 2024-2025 Lie Yan

import Algorithms
import CoreGraphics
import DequeModule
import Testing

@testable import SwiftRohan

final class RayshootTests: TextKitTestsBase {

  init() throws {
    try super.init(createFolder: false)
  }

  @Test
  func coverage() {
    let rootNode = RootNode([
      ParagraphNode([
        EquationNode(
          .inline,
          [
            MatrixNode(
              .pmatrix,
              [
                MatrixNode.Row([
                  ContentNode([TextNode("a")]),
                  ContentNode([TextNode("b")]),
                ]),
                MatrixNode.Row([
                  ContentNode([TextNode("c")]),
                  ContentNode([
                    FractionNode(
                      num: [TextNode("m")],
                      denom: [
                        AttachNode(nuc: [TextNode("x")], sub: [TextNode("2")])
                      ])
                  ]),
                ]),
                MatrixNode.Row([
                  ContentNode([]),
                  ContentNode([TextNode("f")]),
                ]),
              ])
          ])
      ])
    ])

    let documentManager = self.createDocumentManager(rootNode)
    let navigation = documentManager.textSelectionNavigation

    do {
      let location = TextLocation.parse("[↓0,↓0,nuc,↓0,(1,0),↓0]:0")!
      let selection = RhTextSelection(location, affinity: .downstream)

      // move up
      let result1 =
        navigation.destinationSelection(
          for: selection, direction: .up, destination: .character, extending: false)
      let expected1 = "([↓0,↓0,nuc,↓0,(0,0),↓0]:0, downstream)"
      guard let result1 = result1 else {
        Issue.record("No result found")
        return
      }
      #expect("\(result1)" == expected1)

      // move down
      let reslt2 =
        navigation.destinationSelection(
          for: selection, direction: .down, destination: .character, extending: false)
      let expected2 = "([↓0,↓0,nuc,↓0,(2,0)]:0, downstream)"
      guard let result2 = reslt2 else {
        Issue.record("No result found")
        return
      }
      #expect("\(result2)" == expected2)
    }
    // resolved within component
    do {
      let location = TextLocation.parse("[↓0,↓0,nuc,↓0,(1,1),↓0,denom,↓0,sub,↓0]:0")!
      let selection = RhTextSelection(location, affinity: .downstream)
      // move up
      let result1 =
        navigation.destinationSelection(
          for: selection, direction: .up, destination: .character, extending: false)
      let expected1 = "([↓0,↓0,nuc,↓0,(1,1),↓0,denom,↓0,nuc,↓0]:1, upstream)"
      guard let result1 = result1 else {
        Issue.record("No result found")
        return
      }
      #expect("\(result1)" == expected1)
    }
    // relay rayshoot
    do {
      let location = TextLocation.parse("[↓0,↓0,nuc,↓0,(0,1),↓0]:0")!
      let selection = RhTextSelection(location, affinity: .downstream)
      // move up
      let result1 =
        navigation.destinationSelection(
          for: selection, direction: .up, destination: .character, extending: false)
      let expected1 = "([↓0,↓0,nuc,↓0,(0,1),↓0]:0, downstream)"
      guard let result1 = result1 else {
        Issue.record("No result found")
        return
      }
      #expect("\(result1)" == expected1)
    }

    // rayshoot from a node where placeholder is active
    do {
      let location = TextLocation.parse("[↓0,↓0,nuc,↓0,(2,0)]:0")!
      let selection = RhTextSelection(location, affinity: .downstream)
      // move up
      let result1 =
        navigation.destinationSelection(
          for: selection, direction: .up, destination: .character, extending: false)
      let expected1 = "([↓0,↓0,nuc,↓0,(1,0),↓0]:0, downstream)"
      guard let result1 = result1 else {
        Issue.record("No result found")
        return
      }
      #expect("\(result1)" == expected1)
    }
  }

  @Test
  func mathNode_rayshoot() {

    let mathNodes: Array<MathNode> = [
      MathAttributesNode(.limits, [TextNode("abc")]),
      MathStylesNode(.mathcal, [TextNode("abc")]),
      TextModeNode([TextNode("abc")]),
      AccentNode(.widehat, nucleus: [TextNode("abc")]),
      AttachNode(nuc: [TextNode("abc")], sub: [TextNode("2")]),
      FractionNode(num: [TextNode("m")], denom: [TextNode("n")]),
      LeftRightNode(.BRACE, [TextNode("abc")]),
      RadicalNode([TextNode("abc")], index: [TextNode("k")]),
      UnderOverNode(.overbrace, [TextNode("abc")]),
    ]
    let equationNode = EquationNode(.display, ElementStore(mathNodes))

    // Call createDocumentManager() to ensure the tree is laid out.
    _ = self.createDocumentManager(RootNode([equationNode]))

    for node in chain(mathNodes, [equationNode]) {
      _ = node.rayshoot(from: CGPoint(x: 5, y: 5), .nuc, in: .up)
      _ = node.rayshoot(from: CGPoint(x: 5, y: 5), .nuc, in: .down)
    }
  }
}
