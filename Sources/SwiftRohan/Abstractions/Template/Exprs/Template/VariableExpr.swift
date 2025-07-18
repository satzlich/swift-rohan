// Copyright 2024-2025 Lie Yan

/// Named variable
final class VariableExpr: Expr {
  class override var type: ExprType { .variable }

  let name: Identifier

  let textStyles: TextStyles?
  let layoutType: LayoutType
  let containerType: ContainerType
  var isBlockContainer: Bool { containerType == .block }

  init(
    _ name: Identifier, textStyles: TextStyles?, _ layoutType: LayoutType,
    _ containerType: ContainerType? = nil
  ) {
    self.name = name
    self.textStyles = textStyles
    self.layoutType = layoutType
    self.containerType = containerType ?? layoutType.defaultContainerType
    super.init()
  }

  convenience init(
    _ name: String, textStyles: TextStyles? = nil, _ layoutType: LayoutType
  ) {
    let name = Identifier(name)
    self.init(name, textStyles: textStyles, layoutType)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(variable: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case name, textStyles, layoutType, containerType
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(Identifier.self, forKey: .name)
    textStyles = try container.decodeIfPresent(TextStyles.self, forKey: .textStyles)
    layoutType = try container.decode(LayoutType.self, forKey: .layoutType)
    containerType = try container.decode(ContainerType.self, forKey: .containerType)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encodeIfPresent(textStyles, forKey: .textStyles)
    try container.encode(layoutType, forKey: .layoutType)
    try container.encode(containerType, forKey: .containerType)
    try super.encode(to: encoder)
  }
}
