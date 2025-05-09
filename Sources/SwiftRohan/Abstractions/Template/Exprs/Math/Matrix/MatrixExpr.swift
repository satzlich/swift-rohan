// Copyright 2024-2025 Lie Yan

final class MatrixExpr: _GridExpr {
  override class var type: ExprType { .matrix }

  override init(_ rows: [_GridExpr.Row], _ delimiters: DelimiterPair) {
    super.init(rows, delimiters)
  }

  override func with(rows: [Row]) -> MatrixExpr {
    MatrixExpr(rows, delimiters)
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
    super.init(rows, delimiters)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(rows, forKey: .rows)
    try container.encode(delimiters, forKey: .delimiters)
    try super.encode(to: encoder)
  }
}

