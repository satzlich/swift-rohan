// Copyright 2024-2025 Lie Yan

final class FractionExpr: Expr {
  class override var type: ExprType { .fraction }
  let numerator: ContentExpr
  let denominator: ContentExpr
  let isBinomial: Bool

  convenience init(numerator: [Expr], denominator: [Expr], isBinomial: Bool = false) {
    self.init(
      numerator: ContentExpr(numerator),
      denominator: ContentExpr(denominator),
      isBinomial: isBinomial)
  }

  init(numerator: ContentExpr, denominator: ContentExpr, isBinomial: Bool) {
    self.numerator = numerator
    self.denominator = denominator
    self.isBinomial = isBinomial
    super.init()
  }

  func with(numerator: ContentExpr) -> FractionExpr {
    FractionExpr(numerator: numerator, denominator: denominator, isBinomial: isBinomial)
  }

  func with(denominator: ContentExpr) -> FractionExpr {
    FractionExpr(numerator: numerator, denominator: denominator, isBinomial: isBinomial)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(fraction: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case numerator
    case denominator
    case isBinomial
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    numerator = try container.decode(ContentExpr.self, forKey: .numerator)
    denominator = try container.decode(ContentExpr.self, forKey: .denominator)
    isBinomial = try container.decode(Bool.self, forKey: .isBinomial)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(numerator, forKey: .numerator)
    try container.encode(denominator, forKey: .denominator)
    try container.encode(isBinomial, forKey: .isBinomial)
    try super.encode(to: encoder)
  }
}
