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
      _ = node.rowCount
      _ = node.columnCount

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
      if node.subtype.isMultiColumnEnabled {
        node.insertColumn(at: 0, inStorage: true)
        node.removeColumn(at: 0, inStorage: true)
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
      _createMatrix(.aligned),
      _createMatrix(.Bmatrix),
      _createMatrix(.cases),
      _createMatrix(.gathered),
      _createMatrix(.substack),
      _createMultiline(.align),
      _createMultiline(.alignAst),
      _createMultiline(.gather),
      _createMultiline(.gatherAst),
      _createMultiline(.multline),
      _createMultiline(.multlineAst),
    ]
  }

  private static func _createMatrix(_ subtype: MathArray) -> MatrixNode {
    precondition(subtype.requiresMatrixNode)
    if subtype.isMultiColumnEnabled {
      return MatrixNode(
        subtype,
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
    }
    else {
      return MatrixNode(
        subtype,
        [
          MatrixNode.Row([
            MatrixNode.Cell([TextNode("1")])
          ]),
          MatrixNode.Row([
            MatrixNode.Cell([TextNode("4")])
          ]),
        ])
    }
  }

  private static func _createMultiline(_ subtype: MathArray) -> MultilineNode {
    precondition(subtype.requiresMultilineNode)
    return MultilineNode(
      subtype,
      [
        MultilineNode.Row([
          MultilineNode.Cell([TextNode("a")])
        ]),
        MultilineNode.Row([
          MultilineNode.Cell([TextNode("b")])
        ]),
      ])
  }
}
