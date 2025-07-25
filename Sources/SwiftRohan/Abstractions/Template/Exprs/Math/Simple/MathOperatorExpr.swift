import Foundation

final class MathOperatorExpr: Expr {
  override class var type: ExprType { .mathOperator }

  let mathOp: MathOperator

  init(_ mathOp: MathOperator) {
    self.mathOp = mathOp
    super.init()
  }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(mathOperator: self, context)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case command }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    guard let mathOp = MathOperator.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command, in: container,
        debugDescription: "Invalid math operator command: \(command)")
    }
    self.mathOp = mathOp
    super.init()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mathOp.command, forKey: .command)
    try super.encode(to: encoder)
  }

}
