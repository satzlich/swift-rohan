// Copyright 2024-2025 Lie Yan

final class MatrixExpr: ArrayExpr {
  override class var type: ExprType { .matrix }

  override init(_ subtype: Subtype, _ rows: [Row]) {
    super.init(subtype, rows)
  }

  override func with(rows: [Row]) -> MatrixExpr {
    MatrixExpr(subtype, rows)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, subtype }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    let subtype = try container.decode(Subtype.self, forKey: .subtype)
    super.init(subtype, rows)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }
}
