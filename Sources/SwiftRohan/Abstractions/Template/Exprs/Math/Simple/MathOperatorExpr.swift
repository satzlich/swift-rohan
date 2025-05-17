// Copyright 2024-2025 Lie Yan

import Foundation

final class MathOperatorExpr: Expr {
  override class var type: ExprType { .mathOperator }

  let mathOp: MathOperator

  init(_ mathOp: MathOperator) {
    self.mathOp = mathOp
    super.init()
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathOperator: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathOp }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    mathOp = try container.decode(MathOperator.self, forKey: .mathOp)
    super.init()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathOp, forKey: .mathOp)
    try super.encode(to: encoder)
  }

}
