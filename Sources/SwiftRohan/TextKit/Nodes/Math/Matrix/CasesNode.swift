// Copyright 2024-2025 Lie Yan

import Foundation

final class CasesNode: MatrixNode {
  override class var type: NodeType { .cases }

  // MARK: - Clone and Visitor

  override func deepCopy() -> TrueMatrixNode { TrueMatrixNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(cases: self, context)
  }
}
