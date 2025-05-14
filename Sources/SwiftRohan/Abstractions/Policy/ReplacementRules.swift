// Copyright 2024-2025 Lie Yan

import Foundation

public enum ReplacementRules {
  public static let allCases: Array<ReplacementRule> = textRules + mathRules

  private static let textRules: Array<ReplacementRule> = [
    // quote

    // "`" -> "‘"
    .init("`", CommandBody("\u{2018}", .textText)),
    // "‘`" -> "“"
    .init("\u{2018}`", CommandBody("\u{201C}", .textText)),
    // "'" -> "’"
    .init("'", CommandBody("\u{2019}", .textText)),
    // "’" + "'" -> "”"
    .init("\u{2019}'", CommandBody("\u{201D}", .textText)),

    // dash

    // "--" -> "–" (en-dash)
    .init("--", CommandBody("\u{2013}", .textText)),
    // "–" (en-dash) + "-" -> "—" (em-dash)
    .init("\u{2013}-", CommandBody("\u{2014}", .textText)),

    // dots

    // "..." -> "…"
    .init("...", CommandBody("\u{2026}", .textText)),
  ]

  private static let mathRules: Array<ReplacementRule> = _mathRules()

  private static func _mathRules() -> Array<ReplacementRule> {
    var results: Array<ReplacementRule> =
      [
        // basics
        .init("$", CommandBodies.inlineEquation),
        .init("^", CommandBodies.attachMathComponent(.sup)),
        .init("_", CommandBodies.attachMathComponent(.sub)),

        // primes
        .init("'", CommandBody.fromMathSymbol("prime")!),
        .init("\u{2032}'", CommandBody.fromMathSymbol("dprime")!),
        .init("\u{2033}'", CommandBody.fromMathSymbol("trprime")!),

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
