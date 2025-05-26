// Copyright 2024-2025 Lie Yan

import Foundation

final class MathVariantExpr: MathExpr {
  class override var type: ExprType { .mathVariant }

  let styles: MathStyles
  let nucleus: ContentExpr

  init(_ styles: MathStyles, _ nucleus: [Expr]) {
    self.styles = styles
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  init(_ styles: MathStyles, _ nucleus: ContentExpr) {
    self.styles = styles
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> MathVariantExpr {
    MathVariantExpr(styles, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathVariant: self, context)
  }

  override func enumerateComponents() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mstyles, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    styles = try container.decode(MathStyles.self, forKey: .mstyles)
    self.nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(styles, forKey: .mstyles)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
