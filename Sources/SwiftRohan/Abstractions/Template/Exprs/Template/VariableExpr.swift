// Copyright 2024-2025 Lie Yan

/// Named variable
final class VariableExpr: Expr {
  class override var type: ExprType { .variable }

  let name: Identifier
  let layoutType: LayoutType
  let isBlockContainer: Bool

  init(_ name: Identifier, _ layoutType: LayoutType, _ isBlockContainer: Bool) {
    self.name = name
    self.layoutType = layoutType
    self.isBlockContainer = isBlockContainer
    super.init()
  }

  convenience init(_ name: String, _ layoutType: LayoutType, _ isBlockContainer: Bool) {
    let name = Identifier(name)
    self.init(name, layoutType, isBlockContainer)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(variable: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case name, layoutType, isBlockContainer
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(Identifier.self, forKey: .name)
    layoutType = try container.decode(LayoutType.self, forKey: .layoutType)
    isBlockContainer = try container.decode(Bool.self, forKey: .isBlockContainer)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(layoutType, forKey: .layoutType)
    try container.encode(isBlockContainer, forKey: .isBlockContainer)
    try super.encode(to: encoder)
  }
}
