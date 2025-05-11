// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct GridNodeTests {
  @Test
  func coverage() {
    let nodes: Array<_GridNode> = GridNodeTests.allSamples()

    for node in nodes {
      #expect(node.rowCount == 2)
      #expect(node.columnCount == 3)

      for i in 0..<node.rowCount {
        _ = node.getRow(at: i)
      }

      for (i, j) in product(0..<node.rowCount, 0..<node.columnCount) {
        _ = node.getElement(i, j)
      }

      do {
        node.insertRow(at: 1, inStorage: true)
        node.removeRow(at: 1, inStorage: true)
      }
      do {
        node.insertColumn(at: 2, inStorage: true)
        node.removeColumn(at: 2, inStorage: true)
      }

      for (i, j) in product(0..<node.rowCount, 0..<node.columnCount) {
        for direction in [TextSelectionNavigation.Direction.forward, .backward] {
          _ = node.destinationIndex(for: GridIndex(i, j), direction)
        }
      }
    }
  }

  static func allSamples() -> Array<_GridNode> {
    [
      AlignedNode(
        [
          AlignedNode.Row([
            AlignedNode.Element([TextNode("1")]),
            AlignedNode.Element([TextNode("2")]),
            AlignedNode.Element([TextNode("3")]),
          ]),
          AlignedNode.Row([
            AlignedNode.Element([TextNode("4")]),
            AlignedNode.Element([TextNode("5")]),
            AlignedNode.Element([TextNode("6")]),
          ]),
        ]
      ),
      CasesNode([
        CasesNode.Row([
          CasesNode.Element([TextNode("1")]),
          CasesNode.Element([TextNode("2")]),
          CasesNode.Element([TextNode("3")]),
        ]),
        CasesNode.Row([
          CasesNode.Element([TextNode("4")]),
          CasesNode.Element([TextNode("5")]),
          CasesNode.Element([TextNode("6")]),
        ]),
      ]),
      MatrixNode(
        [
          MatrixNode.Row([
            MatrixNode.Element([TextNode("1")]),
            MatrixNode.Element([TextNode("2")]),
            MatrixNode.Element([TextNode("3")]),
          ]),
          MatrixNode.Row([
            MatrixNode.Element([TextNode("4")]),
            MatrixNode.Element([TextNode("5")]),
            MatrixNode.Element([TextNode("6")]),
          ]),
        ], DelimiterPair.BRACE),
    ]
  }
}
