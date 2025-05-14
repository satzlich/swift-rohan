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

        // "$" -> inline-equation
        .init("$", CommandBodies.inlineEquation),
        // "^" -> supscript
        .init("^", CommandBodies.attachMathComponent(.sup)),
        // "_" -> subscript
        .init("_", CommandBodies.attachMathComponent(.sub)),

        // primes

        // "'" -> "′"
        .init("'", CommandBody("\u{2032}", .mathText)),
        // "′'" -> "″"
        .init("\u{2032}'", CommandBody("\u{2033}", .mathText)),
        // "″'" -> "‴"
        .init("\u{2033}'", CommandBody("\u{2034}", .mathText)),

        // "..." -> "…"
        .init("...", CommandBody("\u{2026}", .mathText)),
        // "oo " -> "∞"
        spaceTriggered("oo", "\u{221E}", .mathText),

        // arrows

        // "<-" -> "←"
        .init("<-", CommandBody("\u{2190}", .mathText)),
        // "->" -> "→"
        .init("->", CommandBody("\u{2192}", .mathText)),
        // "=>" -> "⇒"
        .init("=>", CommandBody("\u{21D2}", .mathText)),
        // "-->" -> "⟶"
        .init("-->", CommandBody("\u{27F6}", .mathText)),
        // "==> -> "⟹"
        .init("==>", CommandBody("\u{27F9}", .mathText)),

        // relations

        // ":=" -> "≔"
        .init(":=", CommandBody("\u{2254}", .mathText)),
        // "=:" -> "≕"
        .init("=:", CommandBody("\u{2255}", .mathText)),
        // "!=" -> "≠"
        .init("!=", CommandBody("\u{2260}", .mathText)),
        // "<=" -> "≤"
        .init("<=", CommandBody("\u{2264}", .mathText)),
        // ">=" -> "≥"
        .init(">=", CommandBody("\u{2265}", .mathText)),

        // left-right delimiters

        .init("()", CommandBodies.leftRight("(", ")")),
        .init("[]", CommandBodies.leftRight("[", "]")),
        .init("{}", CommandBodies.leftRight("{", "}")),
        .init("[)", CommandBodies.leftRight("[", ")")),
        .init("(]", CommandBodies.leftRight("(", "]")),
        .init("<>", CommandBodies.leftRight("\u{27E8}", "\u{27E9}")),
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
