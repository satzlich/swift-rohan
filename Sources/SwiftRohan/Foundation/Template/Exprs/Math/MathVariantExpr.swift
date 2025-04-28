// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantExpr: ElementExpr {
  class override var type: ExprType { .mathVariant }

  let mathVariant: MathVariant?
  let bold: Bool?
  let italic: Bool?

  init(_ mathVariant: MathVariant?, bold: Bool?, italic: Bool?, _ children: [Expr]) {
    precondition(mathVariant != nil || bold != nil || italic != nil)
    self.mathVariant = mathVariant
    self.bold = bold
    self.italic = italic
    super.init(children)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case variant, bold, italic }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    mathVariant = try container.decode(MathVariant.self, forKey: .variant)
    bold = try container.decodeIfPresent(Bool.self, forKey: .bold)
    italic = try container.decodeIfPresent(Bool.self, forKey: .italic)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathVariant, forKey: .variant)
    try container.encodeIfPresent(bold, forKey: .bold)
    try container.encodeIfPresent(italic, forKey: .italic)
    try super.encode(to: encoder)
  }

  override func with(children: [Expr]) -> Self {
    Self(mathVariant, bold: bold, italic: italic, children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(mathVariant: self, context)
  }
}
