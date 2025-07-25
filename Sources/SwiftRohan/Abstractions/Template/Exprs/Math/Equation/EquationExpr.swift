final class EquationExpr: MathExpr {
  class override var type: ExprType { .equation }

  let subtype: EquationSubtype
  let nucleus: ContentExpr

  init(_ subtype: EquationSubtype, _ nucleus: ContentExpr) {
    self.subtype = subtype
    self.nucleus = nucleus
    super.init()
  }

  convenience init(_ subtype: EquationSubtype, _ nucleus: Array<Expr> = []) {
    self.init(subtype, ContentExpr(nucleus))
  }

  func with(nucleus: ContentExpr) -> EquationExpr {
    EquationExpr(subtype, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(equation: self, context)
  }

  override func enumerateComponents() -> Array<MathExpr.MathComponent> {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case subtype, nuc }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subtype = try container.decode(EquationSubtype.self, forKey: .subtype)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
