// Copyright 2024-2025 Lie Yan

final class MathKindExpr: MathExpr {
  override class var type: ExprType { .mathKind }

  let mathKind: MathKind
  let nucleus: ContentExpr

  init(_ mathKind: MathKind, _ nucleus: ContentExpr) {
    self.mathKind = mathKind
    self.nucleus = nucleus
    super.init()
  }

  init(_ mathKind: MathKind, _ nucleus: [Expr] = []) {
    self.mathKind = mathKind
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  func with(nucleus: ContentExpr) -> MathKindExpr {
    MathKindExpr(mathKind, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathKind: self, context)
  }

  override func enumerateComponents() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case mathKind, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathKind = try container.decode(MathKind.self, forKey: .mathKind)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathKind, forKey: .mathKind)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
