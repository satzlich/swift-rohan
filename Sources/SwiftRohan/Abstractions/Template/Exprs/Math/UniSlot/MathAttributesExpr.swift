// Copyright 2024-2025 Lie Yan

final class MathAttributesExpr: MathExpr {
  override class var type: ExprType { .mathAttributes }

  let attributes: MathAttributes
  let nucleus: ContentExpr

  init(_ attributes: MathAttributes, _ nucleus: ContentExpr) {
    self.attributes = attributes
    self.nucleus = nucleus
    super.init()
  }

  init(_ attributes: MathAttributes, _ nucleus: Array<Expr> = []) {
    self.attributes = attributes
    self.nucleus = ContentExpr(nucleus)
    super.init()
  }

  func with(nucleus: ContentExpr) -> MathAttributesExpr {
    MathAttributesExpr(attributes, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathAttributes: self, context)
  }

  override func enumerateComponents() -> [MathExpr.MathComponent] {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case command, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let attributes = MathAttributes.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid math attributes command: \(command)")
    }
    self.attributes = attributes
    self.nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(attributes.command, forKey: .command)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }
}
