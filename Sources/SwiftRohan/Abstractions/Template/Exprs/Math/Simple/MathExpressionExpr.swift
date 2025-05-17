// Copyright 2024-2025 Lie Yan

import Foundation

final class MathExpressionExpr: Expr {
  override class var type: ExprType { .mathExpression }

  let mathExpression: MathExpression

  init(_ mathExpression: MathExpression) {
    self.mathExpression = mathExpression
    super.init()
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathExpression: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mexpr }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    mathExpression = try container.decode(MathExpression.self, forKey: .mexpr)
    super.init()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathExpression, forKey: .mexpr)
    try super.encode(to: encoder)
  }
}
