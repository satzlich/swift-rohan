// Copyright 2024-2025 Lie Yan

import Foundation

final class OverlineExpr: MathExpr {
  override class var type: ExprType { .overline }

  let nucleus: ContentExpr

  convenience init(_ nucleus: Array<Expr> = []) {
    self.init(ContentExpr(nucleus))
  }

  init(_ nucleus: ContentExpr) {
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> OverlineExpr {
    OverlineExpr(nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(overline: self, context)
  }

  override func enumerateCompoennts() -> [MathExpr.MathComponent] {
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
