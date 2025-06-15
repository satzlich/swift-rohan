// Copyright 2024-2025 Lie Yan

final class MultilineExpr: ArrayExpr {
  override class var type: ExprType { .multiline }

  required override init(_ subtype: MathArray, _ rows: Array<Row>) {
    super.init(subtype, rows)
  }

  override func with(rows: Array<Row>) -> MultilineExpr {
    MultilineExpr(subtype, rows)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(multiline: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case rows, command }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let subtype = MathArray.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid matrix subtype: \(command)")
    }
    let rows = try container.decode(Array<Row>.self, forKey: .rows)
    super.init(subtype, rows)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try container.encode(rows, forKey: .rows)
    try super.encode(to: encoder)
  }
}
