// Copyright 2024-2025 Lie Yan

import Foundation

class Expr: Codable {
  class var type: ExprType { preconditionFailure("overriding required") }
  final var type: ExprType { Self.type }

  init() {}

  func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> { preconditionFailure("overriding required") }

  // MARK: - Codable

  internal enum CodingKeys: CodingKey { case type }

  required init(from decoder: any Decoder) throws {
    // This is unnecessary, but it's a good practice to check type consistency

    // for unknown expr, the encoded type can be arbitrary
    guard Self.type != .unknown else { return }
    // for known expr, the encoded type must match
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ExprType.self, forKey: .type)
    guard type == Self.type else {
      throw DecodingError.dataCorruptedError(
        forKey: .type, in: container,
        debugDescription: "Expr type mismatch: \(type) vs \(Self.type)"
      )
    }
  }

  func encode(to encoder: any Encoder) throws {
    precondition(type != .unknown, "type must be known")
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(Self.type, forKey: .type)
  }
}
