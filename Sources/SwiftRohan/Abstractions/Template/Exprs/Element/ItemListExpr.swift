// Copyright 2024-2025 Lie Yan

final class ItemListExpr: ElementExpr {
  final override class var type: ExprType { .itemList }

  let subtype: ItemListSubtype

  init(_ subtype: ItemListSubtype, _ items: Array<Expr> = []) {
    self.subtype = subtype
    super.init(items)
  }

  final override func with(children: Array<Expr>) -> Self {
    Self(subtype, children)
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    preconditionFailure()
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case subtype }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subtype = try container.decode(ItemListSubtype.self, forKey: .subtype)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(subtype, forKey: .subtype)
    try super.encode(to: encoder)
  }

}
