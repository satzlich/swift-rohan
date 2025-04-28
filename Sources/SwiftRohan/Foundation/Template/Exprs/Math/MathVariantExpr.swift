// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantExpr: ElementExpr {
  class override var type: ExprType { .mathVariant }

  let mathVariant: MathVariant

  init(_ mathVariant: MathVariant, _ children: [Expr]) {
    self.mathVariant = mathVariant
    super.init(children)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathVariant }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    mathVariant = try container.decode(MathVariant.self, forKey: .mathVariant)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathVariant, forKey: .mathVariant)
    try super.encode(to: encoder)
  }

  override func with(children: [Expr]) -> Self {
    Self(mathVariant, children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(mathVariant: self, context)
  }
}
