// Copyright 2024-2025 Lie Yan

import Foundation

final class CasesNode: MatrixNode {
  override class var type: NodeType { .cases }

  init(_ cases: Array<Element>) {
    let rows = cases.map { MatrixNode.Row([$0]) }
    let delimiters = DelimiterPair(Delimiter("{")!, Delimiter())
    super.init(rows, delimiters, .start)
    self.setAlignment(.start)
  }

  init(deepCopyOf casesNode: CasesNode) {
    super.init(deepCopyOf: casesNode)
  }

  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
    self.setAlignment(.start)
  }

  override func encode(to encoder: any Encoder) throws {
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> CasesNode { CasesNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(cases: self, context)
  }
}
