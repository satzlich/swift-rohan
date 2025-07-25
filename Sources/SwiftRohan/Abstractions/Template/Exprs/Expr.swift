import Foundation

class Expr: Codable {
  class var type: ExprType { preconditionFailure("overriding required") }
  final var type: ExprType { Self.type }

  init() {}

  func accept<V, C, R>(_ visitor: V, _ context: C) -> R where V: ExprVisitor<C, R> {
    preconditionFailure("overriding required")
  }

  // MARK: - Codable

  internal enum CodingKeys: CodingKey { case type }

  required init(from decoder: any Decoder) throws {
    // The check below is unnecessary in terms of correctness, but it is
    // useful for debugging.

    // if the type is unknown, it doesn't matter what we decode.
    if Self.type == .unknown { return }

    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ExprType.self, forKey: .type)

    guard type == Self.type else {
      throw DecodingError.dataCorruptedError(
        forKey: .type, in: container,
        debugDescription: "Expr type mismatch: \(type) vs \(Self.type)")
    }
  }

  func encode(to encoder: any Encoder) throws {
    precondition(type != .unknown)  // type must be known
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(Self.type, forKey: .type)
  }
}
