// Copyright 2024-2025 Lie Yan

final class TextStylesExpr: ElementExpr {
  class override var type: ExprType { .textStyles }

  override func with(children: Array<Expr>) -> Self { Self(subtype, children) }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(textStyles: self, context)
  }

  // MARK: - TextStylesExpr

  let subtype: TextStyles

  init(_ subtype: TextStyles, _ expressions: Array<Expr> = []) {
    self.subtype = subtype
    super.init(expressions)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let subtype = TextStyles.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid textStyles command: \(command)")
    }
    self.subtype = subtype
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype.command, forKey: .command)
    try super.encode(to: encoder)
  }
}
