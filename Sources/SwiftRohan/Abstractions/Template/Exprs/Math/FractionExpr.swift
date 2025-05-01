// Copyright 2024-2025 Lie Yan

final class FractionExpr: Expr {
  class override var type: ExprType { .fraction }
  let numerator: ContentExpr
  let denominator: ContentExpr
  let isBinomial: Bool

  convenience init(num: [Expr], denom: [Expr], isBinomial: Bool = false) {
    self.init(num: ContentExpr(num), denom: ContentExpr(denom), isBinomial: isBinomial)
  }

  init(num: ContentExpr, denom: ContentExpr, isBinomial: Bool) {
    self.numerator = num
    self.denominator = denom
    self.isBinomial = isBinomial
    super.init()
  }

  func with(num: ContentExpr) -> FractionExpr {
    FractionExpr(num: num, denom: denominator, isBinomial: isBinomial)
  }

  func with(denom: ContentExpr) -> FractionExpr {
    FractionExpr(num: numerator, denom: denom, isBinomial: isBinomial)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(fraction: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case num, denom, isBinom }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    numerator = try container.decode(ContentExpr.self, forKey: .num)
    denominator = try container.decode(ContentExpr.self, forKey: .denom)
    isBinomial = try container.decode(Bool.self, forKey: .isBinom)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(numerator, forKey: .num)
    try container.encode(denominator, forKey: .denom)
    try container.encode(isBinomial, forKey: .isBinom)
    try super.encode(to: encoder)
  }
}
