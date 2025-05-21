// Copyright 2024-2025 Lie Yan

final class NamedSymbolExpr: Expr {
  override class var type: ExprType { .namedSymbol }

  let namedSymbol: NamedSymbol

  init(_ namedSymbol: NamedSymbol) {
    self.namedSymbol = namedSymbol
    super.init()
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(namedSymbol: self, context)
  }

  private enum CodingKeys: CodingKey { case nsym }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.namedSymbol = try container.decode(NamedSymbol.self, forKey: .nsym)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(namedSymbol, forKey: .nsym)
    try super.encode(to: encoder)
  }
}
