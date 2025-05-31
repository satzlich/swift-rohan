// Copyright 2024-2025 Lie Yan

final class FractionExpr: MathExpr {
  class override var type: ExprType { .fraction }

  let genfrac: MathGenFrac
  let numerator: ContentExpr
  let denominator: ContentExpr

  convenience init(num: [Expr], denom: [Expr], genfrac: MathGenFrac = .frac) {
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

  override func enumerateComponents() -> [MathExpr.MathComponent] {
    [(MathIndex.num, numerator), (MathIndex.denom, denominator)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case num, denom, subtype }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    numerator = try container.decode(ContentExpr.self, forKey: .num)
    denominator = try container.decode(ContentExpr.self, forKey: .denom)
    genfrac = try container.decode(MathGenFrac.self, forKey: .subtype)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(numerator, forKey: .num)
    try container.encode(denominator, forKey: .denom)
    try container.encode(genfrac, forKey: .subtype)
    try super.encode(to: encoder)
  }
}
