// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import Testing

@testable import SwiftRohan

struct ArrayNodeTests {
  @Test
  func coverage() {
    let nodes: Array<ArrayNode> = ArrayNodeTests.allSamples()

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

  static func allSamples() -> Array<ArrayNode> {
    [
      MatrixNode(
        .pmatrix,
        [
          MatrixNode.Row([
            MatrixNode.Cell([TextNode("1")]),
            MatrixNode.Cell([TextNode("2")]),
            MatrixNode.Cell([TextNode("3")]),
          ]),
          MatrixNode.Row([
            MatrixNode.Cell([TextNode("4")]),
            MatrixNode.Cell([TextNode("5")]),
            MatrixNode.Cell([TextNode("6")]),
          ]),
        ])
    ]
  }
}
