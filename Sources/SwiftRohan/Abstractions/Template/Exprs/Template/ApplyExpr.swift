// Copyright 2024-2025 Lie Yan

/// Template calls, for which `Apply` is a shorthand
final class ApplyExpr: Expr {
  override class var type: ExprType { .apply }

  let templateName: TemplateName
  let arguments: Array<ContentExpr>

  init(_ templateName: TemplateName, arguments: Array<ContentExpr>) {
    self.templateName = templateName
    self.arguments = arguments
    super.init()
  }

  convenience init(_ templateName: String, arguments: [Array<Expr>] = []) {
    self.init(TemplateName(templateName), arguments: arguments.map(ContentExpr.init))
  }

  init(_ template: MathTemplate) {
    self.templateName = template.name
    self.arguments = (0..<template.parameterCount).map { _ in ContentExpr([]) }
    super.init()
  }

  func with(arguments: Array<ContentExpr>) -> ApplyExpr {
    ApplyExpr(templateName, arguments: arguments)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(apply: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case templateName, arguments }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    templateName = try container.decode(TemplateName.self, forKey: .templateName)
    arguments = try container.decode(Array<ContentExpr>.self, forKey: .arguments)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(templateName, forKey: .templateName)
    try container.encode(arguments, forKey: .arguments)
    try super.encode(to: encoder)
  }
}
