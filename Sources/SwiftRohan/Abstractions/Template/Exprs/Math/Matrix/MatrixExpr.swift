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
  where V: ExprVisitor<C, R> {
    visitor.visit(matrix: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, command }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let subtype = Subtype.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid matrix subtype: \(command)")
    }
    let rows = try container.decode([Row].self, forKey: .rows)
    super.init(subtype, rows)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }
}
