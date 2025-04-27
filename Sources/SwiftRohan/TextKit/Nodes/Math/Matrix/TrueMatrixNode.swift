// Copyright 2024-2025 Lie Yan

import Foundation

final class TrueMatrixNode: MatrixNode {
  override class var type: NodeType { .matrix }

  // MARK: - Clone and Visitor

  override func deepCopy() -> TrueMatrixNode { TrueMatrixNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(matrix: self, context)
  }
}
