// Copyright 2024-2025 Lie Yan

final class MathSymbolExpr: Expr {
  override class var type: ExprType { .mathSymbol }

  let mathSymbol: MathSymbol

  init(_ mathSymbol: MathSymbol) {
    self.mathSymbol = mathSymbol
    super.init()
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathSymbol: self, context)
  }

  private enum CodingKeys: CodingKey { case msym }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mathSymbol = try container.decode(MathSymbol.self, forKey: .msym)
    try super.init(from: decoder)
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathSymbol, forKey: .msym)
    try super.encode(to: encoder)
  }
}
