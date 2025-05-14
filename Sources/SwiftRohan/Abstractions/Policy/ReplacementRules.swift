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
        .init("'", CommandBody.from(MathSymbol.lookup("prime")!)),
        .init("\u{2032}'", CommandBody.from(MathSymbol.lookup("dprime")!)),
        .init("\u{2033}'", CommandBody.from(MathSymbol.lookup("trprime")!)),

        .init("...", CommandBody.from(MathSymbol.lookup("ldots")!)),
        spaceTriggered("oo", CommandBody.from(MathSymbol.lookup("infty")!)),

        // arrows
        .init("<-", CommandBody.from(MathSymbol.lookup("leftarrow")!)),
        .init("->", CommandBody.from(MathSymbol.lookup("rightarrow")!)),
        .init("=>", CommandBody.from(MathSymbol.lookup("Rightarrow")!)),
        .init("-->", CommandBody.from(MathSymbol.lookup("longrightarrow")!)),
        .init("==>", CommandBody.from(MathSymbol.lookup("Longrightarrow")!)),

        // relations

        .init("!=", CommandBody.from(MathSymbol.lookup("neq")!)),
        .init("<=", CommandBody.from(MathSymbol.lookup("leq")!)),
        .init(">=", CommandBody.from(MathSymbol.lookup("geq")!)),

        // left-right delimiters

        .init("()", CommandBodies.leftRight("(", ")")),
        .init("[]", CommandBodies.leftRight("[", "]")),
        .init("{}", CommandBodies.leftRight("{", "}")),
        .init("[)", CommandBodies.leftRight("[", ")")),
        .init("(]", CommandBodies.leftRight("(", "]")),
        .init("<>", CommandBodies.leftRight("langle", "rangle")),
        .init("||", CommandBodies.leftRight("|", "|")),
      ]

    do {
      let rules = MathOperator.predefinedCases.map {
        spaceTriggered($0.string, CommandBody.from($0))
      }
      results.append(contentsOf: rules)
    }

    return results
  }

  /// Replacement triggered by `string` + ` ` (space).
  private static func spaceTriggered(
    _ string: String, _ symbol: String, _ category: ContentCategory
  ) -> ReplacementRule {
    ReplacementRule(string, " ", CommandBody(symbol, category))
  }

  /// Replacement triggered by `string` + ` ` (space).
  private static func spaceTriggered(
    _ string: String, _ command: CommandBody
  ) -> ReplacementRule {
    ReplacementRule(string, " ", command)
  }
}
