// Copyright 2024-2025 Lie Yan

import Foundation

final class MathOperatorExpr: Expr {
  override class var type: ExprType { .mathOperator }

  let content: ContentExpr
  let limits: Bool

  init(_ content: [Expr], _ limits: Bool) {
    self.content = ContentExpr(content)
    self.limits = limits
    super.init()
  }

  init(_ content: ContentExpr, _ limits: Bool) {
    self.content = content
    self.limits = limits
    super.init()
  }

  func with(content: ContentExpr) -> MathOperatorExpr {
    MathOperatorExpr(content, limits)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(mathOperator: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case content, limits }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.content = try container.decode(ContentExpr.self, forKey: .content)
    self.limits = try container.decode(Bool.self, forKey: .limits)
    super.init()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(content, forKey: .content)
    try container.encode(limits, forKey: .limits)
    try super.encode(to: encoder)
  }

}
