import Foundation

final class LeftRightExpr: MathExpr {
  override class var type: ExprType { .leftRight }

  let delimiters: DelimiterPair
  let nucleus: ContentExpr

  init(_ delimiters: DelimiterPair, _ nucleus: ContentExpr) {
    self.delimiters = delimiters
    self.nucleus = nucleus
    super.init()
  }

  convenience init(_ delimiters: DelimiterPair, _ nucleus: Array<Expr>) {
    let nucleus = ContentExpr(nucleus)
    self.init(delimiters, nucleus)
  }

  func with(nucleus: ContentExpr) -> LeftRightExpr {
    return LeftRightExpr(delimiters, nucleus)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(leftRight: self, context)
  }

  override func enumerateComponents() -> Array<MathExpr.MathComponent> {
    [(MathIndex.nuc, nucleus)]
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case delim, nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    delimiters = try container.decode(DelimiterPair.self, forKey: .delim)
    nucleus = try container.decode(ContentExpr.self, forKey: .nuc)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(delimiters, forKey: .delim)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

}
