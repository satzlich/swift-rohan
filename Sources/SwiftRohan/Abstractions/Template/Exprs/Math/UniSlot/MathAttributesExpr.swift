// Copyright 2024-2025 Lie Yan

final class MathAttributesExpr: MathExpr {
  override class var type: ExprType { .mathAttributes }

  let attributes: MathAttributes
  let nucleus: ContentExpr

  init(_ attributes: MathAttributes, _ nucleus: ContentExpr) {
    self.attributes = attributes
    self.nucleus = nucleus
    super.init()
  }

  init(_ attributes: MathAttributes, _ nucleus: [Expr] = []) {
    self.attributes = attributes
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  func with(nucleus: ContentExpr) -> MathAttributesExpr {
    MathAttributesExpr(attributes, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathLimits: self, context)
  }

  override func enumerateComponents() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mattrs, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.attributes = try container.decode(MathAttributes.self, forKey: .mattrs)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(attributes, forKey: .mattrs)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
