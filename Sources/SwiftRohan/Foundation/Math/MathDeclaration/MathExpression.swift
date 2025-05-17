// Copyright 2024-2025 Lie Yan

import Foundation

struct MathExpression: MathDeclarationProtocol {
  let command: String
  let body: Expr

  init(_ command: String, _ body: Expr) {
    self.command = command
    self.body = body
  }

  func deflated() -> Node {
    NodeUtils.convertExpr(body)
  }

  enum CodingKeys: CodingKey {
    case command
    case body
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)
    let wildExpr = try container.decode(WildcardExpr.self, forKey: .body)
    self.body = wildExpr.expr
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.command, forKey: .command)
    try container.encode(self.body, forKey: .body)
  }

}

extension MathExpression {
  static let predefinedCases: [MathExpression] = [
    colon
  ]

  private static let _dictionary: [String: MathExpression] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathExpression? {
    _dictionary[command]
  }

  static let colon = MathExpression("colon", MathKindExpr(.mathpunct, [TextExpr(":")]))
}
