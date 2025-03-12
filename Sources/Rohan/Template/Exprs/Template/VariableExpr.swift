// Copyright 2024-2025 Lie Yan

/** Named variable */
final class VariableExpr: Expr {
  class override var type: ExprType { .variable }

  let name: Identifier

  init(_ name: Identifier) {
    self.name = name
    super.init()
  }

  convenience init(_ name: String) {
    self.init(Identifier(name))
  }

  func with(name: Identifier) -> VariableExpr {
    VariableExpr(name)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(variable: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case name
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(Identifier.self, forKey: .name)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try super.encode(to: encoder)
  }
}
