// Copyright 2024-2025 Lie Yan

import Foundation

final class TextModeExpr: MathExpr {
  class override var type: ExprType { .textMode }

  let nucleus: ContentExpr

  init(_ nucleus: ContentExpr) {
    self.nucleus = nucleus
    super.init()
  }

  init(_ nucleus: Array<Expr> = []) {
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  func with(nucleus: ContentExpr) -> TextModeExpr {
    TextModeExpr(nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(textMode: self, context)
  }

  override func enumerateComponents() -> Array<MathExpr.MathComponent> {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
