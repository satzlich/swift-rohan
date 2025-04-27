// Copyright 2024-2025 Lie Yan

import Foundation

final class CasesNode: _MatrixNode {
  override class var type: NodeType { .cases }

  init(_ cases: Array<Element>) {
    let rows = cases.map { _MatrixNode.Row([$0]) }
    let delimiters = CasesExpr.defaultDelimiters
    super.init(rows, delimiters, .start)
  }

  convenience init(_ cases: Array<Array<Node>>) {
    let rows = cases.map { Element($0) }
    self.init(rows)
  }

  init(deepCopyOf casesNode: CasesNode) {
    super.init(deepCopyOf: casesNode)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let cases = try container.decode(Array<Element>.self, forKey: .rows)

    let rows = cases.map { _MatrixNode.Row([$0]) }
    let delimiters = DelimiterPair(Delimiter("{")!, Delimiter())
    super.init(rows, delimiters, .start)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let rows: Array<Element> = self._rows.map { $0[0] }
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }

  func getElement(_ row: Int) -> _MatrixNode.Element {
    _rows[row][0]
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> CasesNode { CasesNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(cases: self, context)
  }
}
