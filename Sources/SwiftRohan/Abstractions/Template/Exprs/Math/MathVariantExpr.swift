// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantExpr: MathExpr {
  class override var type: ExprType { .mathVariant }

  let mathTextStyle: MathTextStyle
  let nucleus: ContentExpr

  init(_ mathTextStyle: MathTextStyle, _ nucleus: [Expr]) {
    self.mathTextStyle = mathTextStyle
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  init(_ mathTextStyle: MathTextStyle, _ nucleus: ContentExpr) {
    self.mathTextStyle = mathTextStyle
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> MathVariantExpr {
    MathVariantExpr(mathTextStyle, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathVariant: self, context)
  }

  override func enumerateCompoennts() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case textStyle, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathTextStyle = try container.decode(MathTextStyle.self, forKey: .textStyle)
    self.nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathTextStyle, forKey: .textStyle)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
