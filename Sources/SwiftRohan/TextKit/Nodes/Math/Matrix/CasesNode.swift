// Copyright 2024-2025 Lie Yan

import Foundation

final class CasesNode: _GridNode {
  override class var type: NodeType { .cases }

  init(_ rows: Array<_GridNode.Row>) {
    super.init(CasesExpr.defaultDelimiters, rows, subtype: .cases)
  }

  init(deepCopyOf casesNode: CasesNode) {
    super.init(deepCopyOf: casesNode)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    let delimiters = DelimiterPair(Delimiter("{")!, Delimiter())
    super.init(delimiters, rows, subtype: .cases)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_rows, forKey: .rows)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> CasesNode { CasesNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(cases: self, context)
  }
}
