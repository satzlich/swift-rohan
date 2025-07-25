import Foundation

final class UnknownExpr: Expr {
  override class var type: ExprType { .unknown }

  override func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExprVisitor<C, R> {
    visitor.visit(unknown: self, context)
  }

  // MARK: - Codable

  let data: JSONValue

  init(_ data: JSONValue) {
    self.data = data
    super.init()
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    data = try container.decode(JSONValue.self)
    super.init()
  }

  override public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(data)
    // no need to encode super as it is not a part of the JSON representation
  }
}
