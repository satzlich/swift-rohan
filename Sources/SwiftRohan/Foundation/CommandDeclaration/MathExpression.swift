// Copyright 2024-2025 Lie Yan

import Foundation

struct MathExpression: CommandDeclarationProtocol {
  enum Subtype: String, Codable {
    /// For function call, a call to the template is output for storage.
    case functionCall
    /// For code snippet, the expanded content is output for storage.
    case codeSnippet
  }

  let command: String
  let body: Expr
  let subtype: Subtype

  init(_ command: String, _ body: Expr, subtype: Subtype = .functionCall) {
    self.command = command
    self.body = body
    self.subtype = subtype
  }

  func deflated() -> Node {
    NodeUtils.convertExpr(body)
  }

  enum CodingKeys: CodingKey {
    case command
    case body
    case subtype
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)
    let wildExpr = try container.decode(WildcardExpr.self, forKey: .body)
    self.body = wildExpr.expr
    self.subtype = try container.decode(Subtype.self, forKey: .subtype)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.command, forKey: .command)
    try container.encode(self.body, forKey: .body)
    try container.encode(self.subtype, forKey: .subtype)
  }
}

extension MathExpression {
  static let predefinedCases: [MathExpression] = [
    bot,
    colon,
    dagger,
    ddagger,
    varDelta,
    varinjlim,
    varliminf,
    varlimsup,
    varprojlim,
  ]

  private static let _dictionary: [String: MathExpression] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathExpression? {
    _dictionary[command]
  }

  // \bot shares the same symbol with \perp, but is of Ord kind.
  static let bot = MathExpression("bot", MathKindExpr(.mathord, [TextExpr("⊥")]))

  static let colon = MathExpression("colon", MathKindExpr(.mathpunct, [TextExpr(":")]))
  static let dagger =
    MathExpression("dagger", MathKindExpr(.mathbin, [TextExpr("\u{2020}")]))
  static let ddagger =
    MathExpression("ddagger", MathKindExpr(.mathbin, [TextExpr("\u{2021}")]))
  static let varDelta =
    MathExpression("varDelta", MathVariantExpr(.mathit, [TextExpr("Δ")]))

  static let varinjlim =
    MathExpression(
      "varinjlim", UnderspreaderExpr(._underrightarrow, [MathOperatorExpr(.lim)]))
  static let varliminf =
    MathExpression("varliminf", UnderspreaderExpr(._lowline, [MathOperatorExpr(.lim)]))
  static let varlimsup =
    MathExpression("varlimsup", OverspreaderExpr(._overline, [MathOperatorExpr(.lim)]))
  static let varprojlim =
    MathExpression(
      "varprojlim", UnderspreaderExpr(._underleftarrow, [MathOperatorExpr(.lim)]))
}
