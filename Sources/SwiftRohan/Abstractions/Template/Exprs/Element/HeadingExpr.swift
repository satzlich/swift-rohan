final class HeadingExpr: ElementExpr {
  class override var type: ExprType { .heading }

  var level: Int { subtype.level }
  var subtype: HeadingSubtype

  init(_ subtype: HeadingSubtype, _ expressions: Array<Expr> = []) {
    self.subtype = subtype
    super.init(expressions)
  }

  override func with(children: Array<Expr>) -> Self {
    Self(subtype, children)
  }

  static func validate(level: Int) -> Bool {
    1...5 ~= level
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(heading: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case subtype }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.subtype = try container.decode(HeadingSubtype.self, forKey: .subtype)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }
}
