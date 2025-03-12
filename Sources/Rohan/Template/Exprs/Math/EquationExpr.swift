// Copyright 2024-2025 Lie Yan

final class EquationExpr: RhExpr {
  class override var type: ExprType { .equation }
  let isBlock: Bool
  let nucleus: ContentExpr

  init(isBlock: Bool, _ nucleus: ContentExpr) {
    self.isBlock = isBlock
    self.nucleus = nucleus
    super.init()
  }

  convenience init(isBlock: Bool, _ nucleus: [RhExpr] = []) {
    self.init(isBlock: isBlock, ContentExpr(nucleus))
  }

  func with(isBlock: Bool) -> EquationExpr {
    EquationExpr(isBlock: isBlock, nucleus)
  }

  func with(nucleus: ContentExpr) -> EquationExpr {
    EquationExpr(isBlock: isBlock, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(equation: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey {
    case isBlock
    case nucleus
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isBlock = try container.decode(Bool.self, forKey: .isBlock)
    nucleus = try container.decode(ContentExpr.self, forKey: .nucleus)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(isBlock, forKey: .isBlock)
    try container.encode(nucleus, forKey: .nucleus)
    try super.encode(to: encoder)
  }
}
