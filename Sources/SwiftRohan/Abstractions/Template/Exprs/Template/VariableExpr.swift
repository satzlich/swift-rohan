// Copyright 2024-2025 Lie Yan

/// Named variable
final class VariableExpr: Expr {
  class override var type: ExprType { .variable }

  let name: Identifier

  let textStyles: TextStyles?
  let layoutType: LayoutType
  let isBlockContainer: Bool

  init(
    _ name: Identifier,
    textStyles: TextStyles?,
    _ layoutType: LayoutType,
    _ isBlockContainer: Bool
  ) {
    self.name = name
    self.textStyles = textStyles
    self.layoutType = layoutType
    self.isBlockContainer = isBlockContainer
    super.init()
  }

  convenience init(
    _ name: String,
    textStyles: TextStyles? = nil,
    _ layoutType: LayoutType,
    _ isBlockContainer: Bool
  ) {
    let name = Identifier(name)
    self.init(name, textStyles: textStyles, layoutType, isBlockContainer)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(variable: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case name, textStyles, layoutType, isBlockContainer
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(Identifier.self, forKey: .name)
    textStyles = try container.decodeIfPresent(TextStyles.self, forKey: .textStyles)
    layoutType = try container.decode(LayoutType.self, forKey: .layoutType)
    isBlockContainer = try container.decode(Bool.self, forKey: .isBlockContainer)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encodeIfPresent(textStyles, forKey: .textStyles)
    try container.encode(layoutType, forKey: .layoutType)
    try container.encode(isBlockContainer, forKey: .isBlockContainer)
    try super.encode(to: encoder)
  }
}
