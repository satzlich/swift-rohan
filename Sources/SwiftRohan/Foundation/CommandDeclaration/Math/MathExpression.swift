// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

struct MathExpression: CommandDeclarationProtocol {
  let command: String
  let body: Expr
  let tag: CommandTag
  var source: CommandSource { .preBuilt }

  init(_ command: String, _ body: Expr, tag: CommandTag) {
    self.command = command
    self.body = body
    self.tag = tag
  }

  func deflated() -> Node {
    NodeUtils.convertExpr(body)
  }

  enum CodingKeys: CodingKey {
    case command
    case body
    case tag
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)
    let wildExpr = try container.decode(WildcardExpr.self, forKey: .body)
    self.body = wildExpr.expr
    self.tag = try container.decode(CommandTag.self, forKey: .tag)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.command, forKey: .command)
    try container.encode(self.body, forKey: .body)
    try container.encode(self.tag, forKey: .tag)
  }
}

extension MathExpression {
  nonisolated(unsafe) static let allCommands: Array<MathExpression> = [
    bmod,
    bot,
    colon,
    dagger,
    ddagger,
    smallint,
    varDelta,
    varinjlim,
    varliminf,
    varlimsup,
    varprojlim,
  ]

  private nonisolated(unsafe) static let _dictionary: Dictionary<String, MathExpression> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathExpression? {
    _dictionary[command]
  }

  nonisolated(unsafe) static let bmod = MathExpression(
    "bmod", MathAttributesExpr(.mathbin, [MathStylesExpr(.mathrm, [TextExpr("mod")])]),
    tag: .null)

  // \bot shares the same symbol with \perp, but is of Ord kind.
  nonisolated(unsafe) static let bot = MathExpression(
    "bot", MathAttributesExpr(.mathord, [TextExpr("⊥")]), tag: .namedSymbol)

  nonisolated(unsafe) static let colon =
    MathExpression(
      "colon", MathAttributesExpr(.mathpunct, [TextExpr(":")]), tag: .null)

  nonisolated(unsafe) static let dagger =
    MathExpression(
      "dagger", MathAttributesExpr(.mathbin, [TextExpr("\u{2020}")]), tag: .namedSymbol)

  nonisolated(unsafe) static let ddagger =
    MathExpression(
      "ddagger", MathAttributesExpr(.mathbin, [TextExpr("\u{2021}")]),
      tag: .namedSymbol)

  nonisolated(unsafe) static let smallint =
    MathExpression(
      "smallint", MathStylesExpr(.toInlineStyle, [TextExpr("∫")]), tag: .null)

  nonisolated(unsafe) static let varDelta =
    MathExpression(
      "varDelta", MathStylesExpr(.mathit, [TextExpr("Δ")]), tag: .namedSymbol)

  nonisolated(unsafe) static let varinjlim =
    MathExpression(
      "varinjlim", UnderOverExpr(._underrightarrow, [MathOperatorExpr(.lim)]),
      tag: .mathOperator)

  nonisolated(unsafe) static let varliminf =
    MathExpression(
      "varliminf", UnderOverExpr(.underline, [MathOperatorExpr(.lim)]),
      tag: .mathOperator)

  nonisolated(unsafe) static let varlimsup =
    MathExpression(
      "varlimsup", UnderOverExpr(.overline, [MathOperatorExpr(.lim)]),
      tag: .mathOperator)

  nonisolated(unsafe) static let varprojlim =
    MathExpression(
      "varprojlim", UnderOverExpr(._underleftarrow, [MathOperatorExpr(.lim)]),
      tag: .mathOperator)
}
