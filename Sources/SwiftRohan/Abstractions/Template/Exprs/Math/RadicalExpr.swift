import Foundation

final class RadicalExpr: MathExpr {
  override class var type: ExprType { .radical }

  let radicand: ContentExpr
  let index: ContentExpr?

  init(_ radicand: ContentExpr, index: ContentExpr?) {
    self.radicand = radicand
    self.index = index
    super.init()
  }

  convenience init(_ radicand: Array<Expr>, index: Array<Expr>? = nil) {
    let radicand = ContentExpr(radicand)
    let index = index.map { ContentExpr($0) }
    self.init(radicand, index: index)
  }

  final func with(radicand: ContentExpr) -> RadicalExpr {
    RadicalExpr(radicand, index: index)
  }

  final func with(index: ContentExpr?) -> RadicalExpr {
    RadicalExpr(radicand, index: index)
  }

  final override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(radical: self, context)
  }

  final override func enumerateComponents() -> Array<MathExpr.MathComponent> {
    var components: Array<MathExpr.MathComponent> = []
    components.append((MathIndex.radicand, radicand))
    if let index = index {
      components.append((MathIndex.index, index))
    }
    return components
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case radicand, index }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    radicand = try container.decode(ContentExpr.self, forKey: .radicand)
    index = try container.decodeIfPresent(ContentExpr.self, forKey: .index)
    try super.init(from: decoder)
  }

  final override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(radicand, forKey: .radicand)
    try container.encodeIfPresent(index, forKey: .index)
    try super.encode(to: encoder)
  }
}
