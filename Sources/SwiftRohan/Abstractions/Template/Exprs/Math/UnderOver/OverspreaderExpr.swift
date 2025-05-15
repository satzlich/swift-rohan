// Copyright 2024-2025 Lie Yan

import Foundation

final class OverspreaderExpr: MathExpr {
  override class var type: ExprType { .overspreader }

  let spreader: MathSpreader
  let nucleus: ContentExpr

  convenience init(_ spreader: MathSpreader, _ nucleus: [Expr]) {
    let nucleus = ContentExpr(nucleus)
    self.init(spreader, nucleus)
  }

  init(_ spreader: MathSpreader, _ nucleus: ContentExpr) {
    precondition(spreader.subtype == .over)
    self.spreader = spreader
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> OverspreaderExpr {
    OverspreaderExpr(spreader, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(overspreader: self, context)
  }

  override func enumerateCompoennts() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case spreader, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.spreader = try container.decode(MathSpreader.self, forKey: .spreader)
    self.nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(spreader, forKey: .spreader)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
