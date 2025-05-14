// Copyright 2024-2025 Lie Yan

import Foundation

final class MatrixNode: ArrayNode {
  override class var type: NodeType { .matrix }

  override init(_ subtype: MathArray, _ rows: Array<ArrayNode.Row>) {
    super.init(subtype, rows)
  }

  init(deepCopyOf matrixNode: MatrixNode) {
    super.init(deepCopyOf: matrixNode)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, subtype }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let subtype = try container.decode(Subtype.self, forKey: .subtype)
    let rows = try container.decode([Row].self, forKey: .rows)
    super.init(subtype, rows)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_rows, forKey: .rows)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> MatrixNode { MatrixNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(matrix: self, context)
  }
}
