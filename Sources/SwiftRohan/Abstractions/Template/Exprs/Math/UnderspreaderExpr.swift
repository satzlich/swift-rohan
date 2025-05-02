// Copyright 2024-2025 Lie Yan

import Foundation

final class UnderspreaderExpr: MathExpr {
  override class var type: ExprType { .underspreader }

  let spreader: Character
  let nucleus: ContentExpr

  init(_ spreader: Character, _ nucleus: [Expr]) {
    self.spreader = spreader
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  init(_ spreader: Character, _ nucleus: ContentExpr) {
    self.spreader = spreader
    self.nucleus = nucleus
    super.init()
  }

  func with(nucleus: ContentExpr) -> UnderspreaderExpr {
    UnderspreaderExpr(spreader, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> {
    visitor.visit(underspreader: self, context)
  }

  override func enumerateCompoennts() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case spreader, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let spreaderString = try container.decode(String.self, forKey: .spreader)
    guard spreaderString.count == 1,
      let spreader = spreaderString.first
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .spreader, in: container,
        debugDescription: "Expected a single character for spreader.")
    }
    self.spreader = spreader

    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)

    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(String(spreader), forKey: .spreader)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

}
