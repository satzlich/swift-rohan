// Copyright 2024-2025 Lie Yan

/** Template calls, for which `Apply` is a shorthand */
final class ApplyExpr: Expr {
  override class var type: ExprType { .apply }

  let templateName: TemplateName
  let arguments: [ContentExpr]

  init(_ templateName: TemplateName, arguments: [ContentExpr]) {
    self.templateName = templateName
    self.arguments = arguments
    super.init()
  }

  convenience init(_ templateName: String, arguments: [Array<Expr>] = []) {
    self.init(TemplateName(templateName), arguments: arguments.map(ContentExpr.init))
  }

  func with(templateName: TemplateName) -> ApplyExpr {
    ApplyExpr(templateName, arguments: arguments)
  }

  func with(arguments: [ContentExpr]) -> ApplyExpr {
    ApplyExpr(templateName, arguments: arguments)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(apply: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys:  CodingKey {
    case templateName
    case arguments
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    templateName = try container.decode(TemplateName.self, forKey: .templateName)
    arguments = try container.decode([ContentExpr].self, forKey: .arguments)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(templateName, forKey: .templateName)
    try container.encode(arguments, forKey: .arguments)
    try super.encode(to: encoder)
  }
}
