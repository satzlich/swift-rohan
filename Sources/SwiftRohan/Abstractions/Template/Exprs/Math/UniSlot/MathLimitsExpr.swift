// Copyright 2024-2025 Lie Yan

final class MathLimitsExpr: MathExpr {
  override class var type: ExprType { .mathLimits }

  let mathLimits: MathLimits
  let nucleus: ContentExpr

  init(_ mathLimits: MathLimits, _ nucleus: ContentExpr) {
    self.mathLimits = mathLimits
    self.nucleus = nucleus
    super.init()
  }

  init(_ mathLimits: MathLimits, _ nucleus: [Expr] = []) {
    self.mathLimits = mathLimits
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  func with(nucleus: ContentExpr) -> MathLimitsExpr {
    MathLimitsExpr(mathLimits, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathLimits: self, context)
  }

  override func enumerateComponents() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathLimits, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathLimits = try container.decode(MathLimits.self, forKey: .mathLimits)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathLimits, forKey: .mathLimits)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
