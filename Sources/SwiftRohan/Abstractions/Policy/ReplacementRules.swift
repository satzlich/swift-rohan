// Copyright 2024-2025 Lie Yan

import Foundation

public enum ReplacementRules {
  public static let allCases: Array<ReplacementRule> = textRules + mathRules

  private static let textRules: Array<ReplacementRule> = [
    // headers
    .init("#", " ", CommandBodies.header(level: 1)),
    .init("##", " ", CommandBodies.header(level: 2)),
    .init("###", " ", CommandBodies.header(level: 3)),
    .init("####", " ", CommandBodies.header(level: 4)),
    .init("#####", " ", CommandBodies.header(level: 5)),

    // quote

    // "`" -> "‘"
    .init("", "`", CommandBody("\u{2018}", .textText)),
    // "‘" + "`" -> "“"
    .init("\u{2018}", "`", CommandBody("\u{201C}", .textText)),
    // "'" -> "’"
    .init("", "'", CommandBody("\u{2019}", .textText)),
    // "’" + "'" -> "”"
    .init("\u{2019}", "'", CommandBody("\u{201D}", .textText)),

    // dash

    // "-" + "-" -> "–" (en-dash)
    .init("-", "-", CommandBody("\u{2013}", .textText)),
    // "–" (en-dash) + "-" -> "—" (em-dash)
    .init("\u{2013}", "-", CommandBody("\u{2014}", .textText)),

    // dots

    // ".." + "." -> "…"
    .init("..", ".", CommandBody("\u{2026}", .textText)),
  ]

  private static let mathRules: Array<ReplacementRule> = [
    // dots

    // ".." + "." -> "…"
    .init("..", ".", CommandBody("\u{2026}", .mathText)),

    // primes

    // "'" -> "′"
    .init("", "'", CommandBody("\u{2032}", .mathText)),
    // "′" + "'" -> "″"
    .init("\u{2032}", "'", CommandBody("\u{2033}", .mathText)),
    // "″" + "'" -> "‴"
    .init("\u{2033}", "'", CommandBody("\u{2034}", .mathText)),

    // arrows

    // "<" + "-" -> "←"
    .init("<", "-", CommandBody("\u{2190}", .mathText)),
    // "-" + ">" -> "→"
    .init("-", ">", CommandBody("\u{2192}", .mathText)),
    // "=" + ">" -> "⇒"
    .init("=", ">", CommandBody("\u{21D2}", .mathText)),
    // "--" + ">" -> "⟶"
    .init("--", ">", CommandBody("\u{27F6}", .mathText)),

    // relations

    // ":" + "=" -> "≔"
    .init(":", "=", CommandBody("\u{2254}", .mathText)),
    // "=" + ":" -> "≕"
    .init("=", ":", CommandBody("\u{2255}", .mathText)),
    // "<" + ">" -> "≠"
    .init("!", "=", CommandBody("\u{2260}", .mathText)),
    // "<" + "=" -> "≤"
    .init("<", "=", CommandBody("\u{2264}", .mathText)),
    // ">" + "=" -> "≥"
    .init(">", "=", CommandBody("\u{2265}", .mathText)),
    // "<" + "<" -> "≪"
    .init("<", "<", CommandBody("\u{226A}", .mathText)),
    // ">" + ">" -> "≫"
    .init(">", ">", CommandBody("\u{226B}", .mathText)),
    // "≪" + "<" -> "⋘"
    .init("\u{226A}", "<", CommandBody("\u{22D8}", .mathText)),
    // "≫" + ">" -> "⋙"
    .init("\u{226B}", ">", CommandBody("\u{22D9}", .mathText)),
    // "~" + "=" -> "≅"
    .init("~", "=", CommandBody("\u{2245}", .mathText)),

    // nodes

    // "$" -> inline-equation
    .init("", "$", CommandBodies.inlineEquation),

    // "^" -> supscript
    .init("", "^", CommandBodies.attachMathComponent(.sup)),
    .init("", "_", CommandBodies.attachMathComponent(.sub)),

    // left-right delimiters
    .init("(", ")", CommandBodies.leftRight("(", ")")),
    .init("[", "]", CommandBodies.leftRight("[", "]")),
    .init("{", "}", CommandBodies.leftRight("{", "}")),
    .init("[", ")", CommandBodies.leftRight("[", ")")),
    .init("(", "]", CommandBodies.leftRight("(", "]")),
    .init("<", ">", CommandBodies.leftRight("\u{27E8}", "\u{27E9}")),
    .init("|", "|", CommandBodies.leftRight("|", "|")),

    // math operators
    .init("arccos", " ", MathOperators.arccos),
    .init("arcsin", " ", MathOperators.arcsin),
    .init("arctan", " ", MathOperators.arctan),
    .init("arg", " ", MathOperators.arg),
    .init("cos", " ", MathOperators.cos),
    .init("cosh", " ", MathOperators.cosh),
    .init("cot", " ", MathOperators.cot),
    .init("coth", " ", MathOperators.coth),
    .init("csc", " ", MathOperators.csc),
    .init("csch", " ", MathOperators.csch),
    .init("ctg", " ", MathOperators.ctg),
    .init("deg", " ", MathOperators.deg),
    .init("det", " ", MathOperators.det),
    .init("dim", " ", MathOperators.dim),
    .init("exp", " ", MathOperators.exp),
    .init("gcd", " ", MathOperators.gcd),
    .init("lcm", " ", MathOperators.lcm),
    .init("hom", " ", MathOperators.hom),
    .init("id", " ", MathOperators.id),
    .init("im", " ", MathOperators.im),
    .init("inf", " ", MathOperators.inf),
    .init("ker", " ", MathOperators.ker),
    .init("lg", " ", MathOperators.lg),
    .init("lim", " ", MathOperators.lim),
    .init("liminf", " ", MathOperators.liminf),
    .init("limsup", " ", MathOperators.limsup),
    .init("ln", " ", MathOperators.ln),
    .init("log", " ", MathOperators.log),
    .init("max", " ", MathOperators.max),
    .init("min", " ", MathOperators.min),
    .init("mod", " ", MathOperators.mod),
    .init("Pr", " ", MathOperators.Pr),
    .init("sec", " ", MathOperators.sec),
    .init("sech", " ", MathOperators.sech),
    .init("sin", " ", MathOperators.sin),
    .init("sinc", " ", MathOperators.sinc),
    .init("sinh", " ", MathOperators.sinh),
    .init("sup", " ", MathOperators.sup),
    .init("tan", " ", MathOperators.tan),
    .init("tanh", " ", MathOperators.tanh),
    .init("tg", " ", MathOperators.tg),
    .init("tr", " ", MathOperators.tr),
  ]
}
