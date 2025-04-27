// Copyright 2024-2025 Lie Yan

import Foundation

final class MatrixNode: _MatrixNode {
  override class var type: NodeType { .matrix }

  init(_ rows: Array<_MatrixNode.Row>, _ delimiters: DelimiterPair) {
    super.init(rows, delimiters, .center)
  }

  init(deepCopyOf matrixNode: MatrixNode) {
    super.init(deepCopyOf: matrixNode)
    self.setAlignment(.center)
  }

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
    self.setAlignment(.center)
  }

  override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MatrixNode { MatrixNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(matrix: self, context)
  }
}
