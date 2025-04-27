// Copyright 2024-2025 Lie Yan

import Foundation

final class MatrixNode: _MatrixNode {
  override class var type: NodeType { .matrix }

  init(_ rows: Array<_MatrixNode.Row>, _ delimiters: DelimiterPair) {
    super.init(rows, delimiters, .center)
  }

  init(deepCopyOf matrixNode: MatrixNode) {
    super.init(deepCopyOf: matrixNode)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, delimiters }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    let delimiters = try container.decode(DelimiterPair.self, forKey: .delimiters)
    super.init(rows, delimiters, .center)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_rows, forKey: .rows)
    try container.encode(_delimiters, forKey: .delimiters)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MatrixNode { MatrixNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(matrix: self, context)
  }
}
