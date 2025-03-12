// Copyright 2024-2025 Lie Yan

final class CompiledVariableExpr: RhExpr {
  class override var type: ExprType { .cVariable }

  /** index to the referenced __template parameter__ */
  let argumentIndex: Int

  init(_ argumentIndex: Int) {
    precondition(Self.validate(argumentIndex: argumentIndex))
    self.argumentIndex = argumentIndex
    super.init()
  }

  static func validate(argumentIndex: Int) -> Bool {
    argumentIndex >= 0
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(cVariable: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case index
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    argumentIndex = try container.decode(Int.self, forKey: .index)
    precondition(Self.validate(argumentIndex: argumentIndex))
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(argumentIndex, forKey: .index)
    try super.encode(to: encoder)
  }
}
