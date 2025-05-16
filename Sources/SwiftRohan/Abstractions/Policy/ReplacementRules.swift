// Copyright 2024-2025 Lie Yan

import Foundation

public enum ReplacementRules {
  public static let allCases: Array<ReplacementRule> = textRules + mathRules

  private static let textRules: Array<ReplacementRule> = [
    // quote
    .init("`", CommandBody("‘", .textText)),  // ` -> U+2018
    .init("‘`", CommandBody("“", .textText)),  // U+2018` -> U+201C
    .init("'", CommandBody("’", .textText)),  // ' -> U+2019
    .init("’'", CommandBody("”", .textText)),  // U+2019 ' -> U+201D
    // dash
    .init("--", CommandBody("–", .textText)),  // -- -> U+2013 (en-dash)
    .init("–-", CommandBody("—", .textText)),  // U+2013- -> U+2014 (em-dash)
    // dots
    .init("...", CommandBody("…", .textText)),  // ... -> U+2026
  ]

  private static let mathRules: Array<ReplacementRule> = _mathRules()

  private static func _mathRules() -> Array<ReplacementRule> {
    var results: Array<ReplacementRule> =
      [
        // basics
        .init("$", CommandBodies.inlineMath),
        .init("^", CommandBodies.attachMathComponent(.sup)),
        .init("_", CommandBodies.attachMathComponent(.sub)),

        // primes (`\prime`, `\dprime`, `\trprime`)
        .init("'", CommandBody("′", .mathText)),  // ' -> U+2032
        .init("′'", CommandBody("″", .mathText)),  // U+2032' -> U+2033
        .init("″'", CommandBody("‴", .mathText)),  // U+2033' -> U+2034

        .init("...", CommandBody.fromMathSymbol("ldots")!),
        spaceTriggered("oo", CommandBody.fromMathSymbol("infty")!),

        // arrows
        .init("<-", CommandBody.fromMathSymbol("leftarrow")!),
        .init("->", CommandBody.fromMathSymbol("rightarrow")!),
        .init("=>", CommandBody.fromMathSymbol("Rightarrow")!),
        .init("-->", CommandBody.fromMathSymbol("longrightarrow")!),
        .init("==>", CommandBody.fromMathSymbol("Longrightarrow")!),

        // relations

        .init("!=", CommandBody.fromMathSymbol("neq")!),
        .init("<=", CommandBody.fromMathSymbol("leq")!),
        .init(">=", CommandBody.fromMathSymbol("geq")!),

        // left-right delimiters

        .init("()", CommandBodies.leftRight("(", ")")!),
        .init("[]", CommandBodies.leftRight("[", "]")!),
        .init("{}", CommandBodies.leftRight("{", "}")!),
        .init("[)", CommandBodies.leftRight("[", ")")!),
        .init("(]", CommandBodies.leftRight("(", "]")!),
        .init("<>", CommandBodies.leftRight("langle", "rangle")!),
        .init("||", CommandBodies.leftRight("|", "|")!),
      ]

    do {
      let rules = MathOperator.predefinedCases.map {
        spaceTriggered($0.command, CommandBody.from($0))
      }
      results.append(contentsOf: rules)
    }

    return results
  }

  /// Replacement triggered by `string` + ` ` (space).
  private static func spaceTriggered(
    _ string: String, _ command: CommandBody
  ) -> ReplacementRule {
    ReplacementRule(string, " ", command)
  }
}
