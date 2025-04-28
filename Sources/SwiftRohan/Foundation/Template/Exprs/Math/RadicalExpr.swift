// Copyright 2024-2025 Lie Yan

import Foundation

final class RadicalExpr: Expr {
  override class var type: ExprType { .radical }

  let radicand: ContentExpr
  let index: ContentExpr?

  init(_ radicand: ContentExpr, _ index: ContentExpr?) {
    self.radicand = radicand
    self.index = index
    super.init()
  }

  init(_ radicand: [Expr], _ index: [Expr]?) {
    self.radicand = ContentExpr(radicand)
    self.index = index.map { ContentExpr($0) }
    super.init()
  }

  func with(radicand: ContentExpr) -> RadicalExpr {
    RadicalExpr(radicand, index)
  }

  func with(index: ContentExpr?) -> RadicalExpr {
    RadicalExpr(radicand, index)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(radical: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case radicand, index }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    radicand = try container.decode(ContentExpr.self, forKey: .radicand)
    index = try container.decodeIfPresent(ContentExpr.self, forKey: .index)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(radicand, forKey: .radicand)
    try container.encodeIfPresent(index, forKey: .index)
    try super.encode(to: encoder)
  }

}
