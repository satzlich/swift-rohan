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

  private static let mathRules: Array<ReplacementRule> = [
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

    // math operators

    spaceTriggered("arccos", MathOperators.arccos),
    spaceTriggered("arcsin", MathOperators.arcsin),
    spaceTriggered("arctan", MathOperators.arctan),
    spaceTriggered("arg", MathOperators.arg),
    spaceTriggered("cos", MathOperators.cos),
    spaceTriggered("cosh", MathOperators.cosh),
    spaceTriggered("cot", MathOperators.cot),
    spaceTriggered("coth", MathOperators.coth),
    spaceTriggered("csc", MathOperators.csc),
    spaceTriggered("csch", MathOperators.csch),
    spaceTriggered("ctg", MathOperators.ctg),
    spaceTriggered("deg", MathOperators.deg),
    spaceTriggered("det", MathOperators.det),
    spaceTriggered("dim", MathOperators.dim),
    spaceTriggered("exp", MathOperators.exp),
    spaceTriggered("gcd", MathOperators.gcd),
    spaceTriggered("lcm", MathOperators.lcm),
    spaceTriggered("hom", MathOperators.hom),
    spaceTriggered("id", MathOperators.id),
    spaceTriggered("im", MathOperators.im),
    spaceTriggered("inf", MathOperators.inf),
    spaceTriggered("ker", MathOperators.ker),
    spaceTriggered("lg", MathOperators.lg),
    spaceTriggered("lim", MathOperators.lim),
    spaceTriggered("liminf", MathOperators.liminf),
    spaceTriggered("limsup", MathOperators.limsup),
    spaceTriggered("ln", MathOperators.ln),
    spaceTriggered("log", MathOperators.log),
    spaceTriggered("max", MathOperators.max),
    spaceTriggered("min", MathOperators.min),
    spaceTriggered("mod", MathOperators.mod),
    spaceTriggered("Pr", MathOperators.Pr),
    spaceTriggered("sec", MathOperators.sec),
    spaceTriggered("sech", MathOperators.sech),
    spaceTriggered("sin", MathOperators.sin),
    spaceTriggered("sinc", MathOperators.sinc),
    spaceTriggered("sinh", MathOperators.sinh),
    spaceTriggered("sup", MathOperators.sup),
    spaceTriggered("tan", MathOperators.tan),
    spaceTriggered("tanh", MathOperators.tanh),
    spaceTriggered("tg", MathOperators.tg),
    spaceTriggered("tr", MathOperators.tr),
  ]

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
