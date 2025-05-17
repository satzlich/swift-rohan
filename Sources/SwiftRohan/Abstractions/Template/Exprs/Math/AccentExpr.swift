// Copyright 2024-2025 Lie Yan

import Foundation

final class AccentExpr: MathExpr {
  override class var type: ExprType { .accent }

  let accent: MathAccent
  let nucleus: ContentExpr

  convenience init(_ accent: MathAccent, _ nucleus: [Expr]) {
    let nucleus = ContentExpr(nucleus)
    self.init(accent, nucleus)
  }

  init(_ accent: MathAccent, _ nucleus: ContentExpr) {
    self.accent = accent
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> AccentExpr {
    AccentExpr(accent, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(accent: self, context)
  }

  override func enumerateCompoennts() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case accent, nuc }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    accent = try container.decode(MathAccent.self, forKey: .accent)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(accent, forKey: .accent)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

}
