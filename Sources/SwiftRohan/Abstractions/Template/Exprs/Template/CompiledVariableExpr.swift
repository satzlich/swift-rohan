// Copyright 2024-2025 Lie Yan

final class CompiledVariableExpr: Expr {
  class override var type: ExprType { .cVariable }

  /// index to the referenced __template parameter/argument__
  let argumentIndex: Int
  /// Delta of the nested level of the variable.
  let nestedLevelDetla: Int

  let layoutType: LayoutType
  let isBlockContainer: Bool

  init(
    _ argumentIndex: Int, nestedLevelDelta: Int = 0,
    _ layoutType: LayoutType,
    _ isBlockContainer: Bool
  ) {
    precondition(CompiledVariableExpr.validate(argumentIndex: argumentIndex))
    self.argumentIndex = argumentIndex
    self.nestedLevelDetla = nestedLevelDelta
    self.layoutType = layoutType
    self.isBlockContainer = isBlockContainer
    super.init()
  }

  static func validate(argumentIndex: Int) -> Bool {
    argumentIndex >= 0
  }

  func with(nestedLevelDelta delta: Int) -> CompiledVariableExpr {
    CompiledVariableExpr(
      argumentIndex, nestedLevelDelta: delta,
      layoutType,
      isBlockContainer)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(cVariable: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case argIndex, levelDelta, layoutType, isBlockContainer
  }

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
    layoutType = try container.decode(LayoutType.self, forKey: .layoutType)
    isBlockContainer = try container.decode(Bool.self, forKey: .isBlockContainer)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(argumentIndex, forKey: .argIndex)
    try container.encode(nestedLevelDetla, forKey: .levelDelta)
    try container.encode(layoutType, forKey: .layoutType)
    try container.encode(isBlockContainer, forKey: .isBlockContainer)
    try super.encode(to: encoder)
  }
}
