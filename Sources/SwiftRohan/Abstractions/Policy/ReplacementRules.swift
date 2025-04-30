// Copyright 2024-2025 Lie Yan

import Foundation

public enum ReplacementRules {
  public static let allCases: Array<ReplacementRule> = textRules + mathRules

  private static let textRules: Array<ReplacementRule> = [
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

    // left-right delimiters
    .init("(", ")", CommandBodies.leftRight("(", ")")),
    .init("[", "]", CommandBodies.leftRight("[", "]")),
    .init("{", "}", CommandBodies.leftRight("{", "}")),
    .init("[", ")", CommandBodies.leftRight("[", ")")),
    .init("(", "]", CommandBodies.leftRight("(", "]")),
    .init("<", ">", CommandBodies.leftRight("\u{27E8}", "\u{27E9}")),
    .init("|", "|", CommandBodies.leftRight("|", "|")),
  ]

}
