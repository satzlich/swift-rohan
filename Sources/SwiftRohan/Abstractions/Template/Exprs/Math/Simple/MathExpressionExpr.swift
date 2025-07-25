import Foundation

final class MathExpressionExpr: Expr {
  override class var type: ExprType { .mathExpression }

  internal let mathExpression: MathExpression

  init(_ mathExpression: MathExpression) {
    self.mathExpression = mathExpression
    super.init()
  }

  final override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathExpression: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let mathExpression = MathExpression.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid math expression command: \(command)")
    }
    self.mathExpression = mathExpression
    super.init()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathExpression.command, forKey: .command)
    try super.encode(to: encoder)
  }
}
