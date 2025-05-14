// Copyright 2024-2025 Lie Yan

final class MatrixExpr: ArrayExpr {
  override class var type: ExprType { .matrix }

  override init(_ delimiters: DelimiterPair, _ rows: [Row]) {
    super.init(delimiters, rows)
  }

  override func with(rows: [Row]) -> MatrixExpr {
    MatrixExpr(delimiters, rows)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, delimiters }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rows = try container.decode([Row].self, forKey: .rows)
    let delimiters = try container.decode(DelimiterPair.self, forKey: .delimiters)
    super.init(delimiters, rows)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try container.encode(delimiters, forKey: .delimiters)
    try super.encode(to: encoder)
  }
}
