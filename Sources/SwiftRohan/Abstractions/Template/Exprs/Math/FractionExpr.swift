final class FractionExpr: MathExpr {
  class override var type: ExprType { .fraction }

  let genfrac: MathGenFrac
  let numerator: ContentExpr
  let denominator: ContentExpr

  convenience init(num: Array<Expr>, denom: Array<Expr>, genfrac: MathGenFrac = .frac) {
    self.init(num: ContentExpr(num), denom: ContentExpr(denom), genfrac: genfrac)
  }

  init(num: ContentExpr, denom: ContentExpr, genfrac: MathGenFrac) {
    self.numerator = num
    self.denominator = denom
    self.genfrac = genfrac
    super.init()
  }

  func with(numerator: ContentExpr) -> FractionExpr {
    FractionExpr(num: numerator, denom: denominator, genfrac: genfrac)
  }

  func with(denominator: ContentExpr) -> FractionExpr {
    FractionExpr(num: numerator, denom: denominator, genfrac: genfrac)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(fraction: self, context)
  }

  override func enumerateComponents() -> Array<MathExpr.MathComponent> {
    [(MathIndex.num, numerator), (MathIndex.denom, denominator)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case num, denom, command }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let command = try container.decode(String.self, forKey: .command)
    guard let genfrac = MathGenFrac.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Unknown genfrac command: \(command)")
    }

    self.genfrac = genfrac
    self.numerator = try container.decode(ContentExpr.self, forKey: .num)
    self.denominator = try container.decode(ContentExpr.self, forKey: .denom)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(genfrac.command, forKey: .command)
    try container.encode(numerator, forKey: .num)
    try container.encode(denominator, forKey: .denom)
    try super.encode(to: encoder)
  }
}
