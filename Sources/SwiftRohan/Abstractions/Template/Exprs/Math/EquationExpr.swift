// Copyright 2024-2025 Lie Yan

final class EquationExpr: MathExpr {
  class override var type: ExprType { .equation }
  let isBlock: Bool
  let nucleus: ContentExpr

  init(isBlock: Bool, nuc: ContentExpr) {
    self.isBlock = isBlock
    self.nucleus = nuc
    super.init()
  }

  convenience init(isBlock: Bool, nuc: [Expr] = []) {
    self.init(isBlock: isBlock, nuc: ContentExpr(nuc))
  }

  func with(isBlock: Bool) -> EquationExpr {
    EquationExpr(isBlock: isBlock, nuc: nucleus)
  }

  func with(nuc: ContentExpr) -> EquationExpr {
    EquationExpr(isBlock: isBlock, nuc: nuc)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(equation: self, context)
  }

  override func enumerateCompoennts() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case isBlock, nuc }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isBlock = try container.decode(Bool.self, forKey: .isBlock)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(isBlock, forKey: .isBlock)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
