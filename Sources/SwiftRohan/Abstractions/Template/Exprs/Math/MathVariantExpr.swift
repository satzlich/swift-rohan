// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantExpr: ElementExpr {
  class override var type: ExprType { .mathVariant }

  let mathTextStyle: MathTextStyle

  init(_ mathTextStyle: MathTextStyle, _ children: [Expr]) {
    self.mathTextStyle = mathTextStyle
    super.init(children)
  }

  override func with(children: [Expr]) -> Self {
    Self(mathTextStyle, children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(mathVariant: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case textStyle }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathTextStyle = try container.decode(MathTextStyle.self, forKey: .textStyle)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathTextStyle, forKey: .textStyle)
    try super.encode(to: encoder)
  }
}
