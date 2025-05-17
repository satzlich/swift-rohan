// Copyright 2024-2025 Lie Yan

import Foundation

struct MathExpression: MathDeclarationProtocol {
  let command: String
  let body: Expr

  init(_ command: String, _ body: Expr) {
    self.command = command
    self.body = body
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
