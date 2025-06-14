// Copyright 2024-2025 Lie Yan

import Foundation

final class UnderOverExpr: MathExpr {
  override class var type: ExprType { .underOver }

  let spreader: MathSpreader
  let nucleus: ContentExpr

  convenience init(_ spreader: MathSpreader, _ nucleus: Array<Expr>) {
    let nucleus = ContentExpr(nucleus)
    self.init(spreader, nucleus)
  }

  init(_ spreader: MathSpreader, _ nucleus: ContentExpr) {
    self.spreader = spreader
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> UnderOverExpr {
    UnderOverExpr(spreader, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(underOver: self, context)
  }

  override func enumerateComponents() -> Array<MathExpr.MathComponent> {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case command, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let command = try container.decode(String.self, forKey: .command)
    guard let spreader = MathSpreader.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid spreader command: \(command)")
    }
    self.spreader = spreader
    self.nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(spreader.command, forKey: .command)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
