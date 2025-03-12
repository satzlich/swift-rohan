// Copyright 2024-2025 Lie Yan

import Foundation

class RhExpr: Codable {  // "Rh" for "Rohan", to avoid name confilict with Foundation.Expression
  class var type: ExprType { preconditionFailure("overriding required") }
  final var type: ExprType { Self.type }

  init() {}

  func accept<V, C, R>(_ visitor: V, _ context: C) -> R
  where V: ExpressionVisitor<C, R> { preconditionFailure("overriding required") }

  // MARK: - Codable

  internal enum CodingKeys: CodingKey {
    case type
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ExprType.self, forKey: .type)
    guard type == Self.type else {
      throw DecodingError.dataCorruptedError(
        forKey: .type, in: container, debugDescription: "type mismatch")
    }
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(Self.type, forKey: .type)
  }
}
