// Copyright 2024-2025 Lie Yan

final class CompiledVariableExpr: Expr {
  class override var type: ExprType { .cVariable }

  /// index to the referenced __template parameter/argument__
  let argumentIndex: Int
  /// Delta of the nested level of the variable.
  let nestedLevelDetla: Int

  init(_ argumentIndex: Int, nestedLevelDelta: Int = 0) {
    precondition(CompiledVariableExpr.validate(argumentIndex: argumentIndex))
    self.argumentIndex = argumentIndex
    self.nestedLevelDetla = nestedLevelDelta
    super.init()
  }

  static func validate(argumentIndex: Int) -> Bool {
    argumentIndex >= 0
  }

  func with(nestedLevelDelta delta: Int) -> CompiledVariableExpr {
    CompiledVariableExpr(argumentIndex, nestedLevelDelta: delta)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(cVariable: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case argIndex, levelDelta }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    argumentIndex = try container.decode(Int.self, forKey: .argIndex)
    guard CompiledVariableExpr.validate(argumentIndex: argumentIndex)
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .argIndex, in: container,
        debugDescription: "Invalid argument index \(argumentIndex)")
    }
    nestedLevelDetla = try container.decode(Int.self, forKey: .levelDelta)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(argumentIndex, forKey: .argIndex)
    try container.encode(nestedLevelDetla, forKey: .levelDelta)
    try super.encode(to: encoder)
  }
}
