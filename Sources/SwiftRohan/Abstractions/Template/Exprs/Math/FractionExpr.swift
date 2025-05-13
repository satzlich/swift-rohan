// Copyright 2024-2025 Lie Yan

final class FractionExpr: MathExpr {
  class override var type: ExprType { .fraction }

  public enum Subtype: Codable {
    case frac
    case binom
    case atop
  }

  let numerator: ContentExpr
  let denominator: ContentExpr
  let subtype: Subtype

  convenience init(num: [Expr], denom: [Expr], subtype: Subtype = .frac) {
    self.init(num: ContentExpr(num), denom: ContentExpr(denom), subtype: subtype)
  }

  init(num: ContentExpr, denom: ContentExpr, subtype: Subtype) {
    self.numerator = num
    self.denominator = denom
    self.subtype = subtype
    super.init()
  }

  func with(numerator: ContentExpr) -> FractionExpr {
    FractionExpr(num: numerator, denom: denominator, subtype: subtype)
  }

  func with(denominator: ContentExpr) -> FractionExpr {
    FractionExpr(num: numerator, denom: denominator, subtype: subtype)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(fraction: self, context)
  }

  override func enumerateCompoennts() -> [MathExpr.MathComponent] {
    [(MathIndex.num, numerator), (MathIndex.denom, denominator)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case num, denom, subtype }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    numerator = try container.decode(ContentExpr.self, forKey: .num)
    denominator = try container.decode(ContentExpr.self, forKey: .denom)
    subtype = try container.decode(Subtype.self, forKey: .subtype)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(numerator, forKey: .num)
    try container.encode(denominator, forKey: .denom)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }
}
