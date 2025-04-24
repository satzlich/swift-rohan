// Copyright 2024-2025 Lie Yan

import Foundation

final class AccentExpr: Expr {
  override class var type: ExprType { .accent }

  let accent: Character
  let nucleus: ContentExpr

  init(_ accent: Character, nucleus: [Expr]) {
    self.accent = accent
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  init(_ accent: Character, nucleus: ContentExpr) {
    self.accent = accent
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> AccentExpr {
    AccentExpr(accent, nucleus: nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(accent: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case accent, nuc }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let accent = try container.decode(String.self, forKey: .accent)

    guard accent.count == 1,
      let first = accent.first
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .accent, in: container,
        debugDescription: "Accent must be a single character")
    }
    self.accent = first

    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(String(accent), forKey: .accent)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

}
