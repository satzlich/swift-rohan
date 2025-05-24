// Copyright 2024-2025 Lie Yan

import Foundation

struct MathExpression: CommandDeclarationProtocol {
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
  static let allCommands: [MathExpression] = [
    bmod,
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
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathExpression? {
    _dictionary[command]
  }

  static let bmod = MathExpression(
    "bmod", MathKindExpr(.mathbin, [MathVariantExpr(.mathrm, [TextExpr("mod")])]))

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
