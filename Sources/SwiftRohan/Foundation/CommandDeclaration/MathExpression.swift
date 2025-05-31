// Copyright 2024-2025 Lie Yan

import Foundation
import LaTeXParser

struct MathExpression: CommandDeclarationProtocol {
  let command: String
  let body: Expr
  let genre: CommandGenre
  var source: CommandSource { .builtIn }

  init(_ command: String, _ body: Expr, genre: CommandGenre) {
    self.command = command
    self.body = body
    self.genre = genre
  }

  func deflated() -> Node {
    NodeUtils.convertExpr(body)
  }

  enum CodingKeys: CodingKey {
    case command
    case body
    case genre
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.command = try container.decode(String.self, forKey: .command)
    let wildExpr = try container.decode(WildcardExpr.self, forKey: .body)
    self.body = wildExpr.expr
    self.genre = try container.decode(CommandGenre.self, forKey: .genre)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.command, forKey: .command)
    try container.encode(self.body, forKey: .body)
    try container.encode(self.genre, forKey: .genre)
  }
}

extension MathExpression {
  static let allCommands: [MathExpression] = [
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

  private static let _dictionary: [String: MathExpression] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathExpression? {
    _dictionary[command]
  }

  static let bmod = MathExpression(
    "bmod", MathAttributesExpr(.mathbin, [MathStylesExpr(.mathrm, [TextExpr("mod")])]),
    genre: .other)

  // \bot shares the same symbol with \perp, but is of Ord kind.
  static let bot = MathExpression(
    "bot", MathAttributesExpr(.mathord, [TextExpr("⊥")]), genre: .namedSymbol)

  static let colon =
    MathExpression(
      "colon", MathAttributesExpr(.mathpunct, [TextExpr(":")]), genre: .other)
  static let dagger =
    MathExpression(
      "dagger", MathAttributesExpr(.mathbin, [TextExpr("\u{2020}")]),
      genre: .namedSymbol)
  static let ddagger =
    MathExpression(
      "ddagger", MathAttributesExpr(.mathbin, [TextExpr("\u{2021}")]),
      genre: .namedSymbol)

  static let smallint =
    MathExpression(
      "smallint", MathStylesExpr(.inlineStyle, [TextExpr("∫")]), genre: .other)

  static let varDelta =
    MathExpression(
      "varDelta", MathStylesExpr(.mathit, [TextExpr("Δ")]), genre: .namedSymbol)

  static let varinjlim =
    MathExpression(
      "varinjlim", UnderOverExpr(._underrightarrow, [MathOperatorExpr(.lim)]),
      genre: .mathOperator)
  static let varliminf =
    MathExpression(
      "varliminf", UnderOverExpr(.underline, [MathOperatorExpr(.lim)]),
      genre: .mathOperator)
  static let varlimsup =
    MathExpression(
      "varlimsup", UnderOverExpr(.overline, [MathOperatorExpr(.lim)]),
      genre: .mathOperator)
  static let varprojlim =
    MathExpression(
      "varprojlim", UnderOverExpr(._underleftarrow, [MathOperatorExpr(.lim)]),
      genre: .mathOperator)
}
