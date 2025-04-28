// Copyright 2024-2025 Lie Yan

import Foundation

public enum ReplacementRules {
  public static let allCases: Array<ReplacementRule> = textRules + mathRules

  private static let textRules: Array<ReplacementRule> = [
    // quote

    // "`" -> "‘"
    .init("", "`", CommandBody("\u{2018}", .textContent)),
    // "‘" + "`" -> "“"
    .init("\u{2018}", "`", CommandBody("\u{201C}", .textContent)),
    // "'" -> "’"
    .init("", "'", CommandBody("\u{2019}", .textContent)),
    // "’" + "'" -> "”"
    .init("\u{2019}", "'", CommandBody("\u{201D}", .textContent)),

    // dash

    // "-" + "-" -> "–" (en-dash)
    .init("-", "-", CommandBody("\u{2013}", .textContent)),
    // "–" (en-dash) + "-" -> "—" (em-dash)
    .init("\u{2013}", "-", CommandBody("\u{2014}", .textContent)),

    // dots

    // ".." + "." -> "…"
    .init("..", ".", CommandBody("\u{2026}", .textContent)),
  ]

  private static let mathRules: Array<ReplacementRule> = [
    // dots

    // ".." + "." -> "…"
    .init("..", ".", CommandBody("\u{2026}", .mathTextContent)),

    // primes

    // "'" -> "′"
    .init("", "'", CommandBody("\u{2032}", .mathTextContent)),
    // "′" + "'" -> "″"
    .init("\u{2032}", "'", CommandBody("\u{2033}", .mathTextContent)),
    // "″" + "'" -> "‴"
    .init("\u{2033}", "'", CommandBody("\u{2034}", .mathTextContent)),

    // arrows

    // "<" + "-" -> "←"
    .init("<", "-", CommandBody("\u{2190}", .mathTextContent)),
    // "-" + ">" -> "→"
    .init("-", ">", CommandBody("\u{2192}", .mathTextContent)),
    // "=" + ">" -> "⇒"
    .init("=", ">", CommandBody("\u{21D2}", .mathTextContent)),
    // "--" + ">" -> "⟶"
    .init("--", ">", CommandBody("\u{27F6}", .mathTextContent)),

    // relations

    // ":" + "=" -> "≔"
    .init(":", "=", CommandBody("\u{2254}", .mathTextContent)),
    // "=" + ":" -> "≕"
    .init("=", ":", CommandBody("\u{2255}", .mathTextContent)),
    // "<" + ">" -> "≠"
    .init("!", "=", CommandBody("\u{2260}", .mathTextContent)),
    // "<" + "=" -> "≤"
    .init("<", "=", CommandBody("\u{2264}", .mathTextContent)),
    // ">" + "=" -> "≥"
    .init(">", "=", CommandBody("\u{2265}", .mathTextContent)),
    // "<" + "<" -> "≪"
    .init("<", "<", CommandBody("\u{226A}", .mathTextContent)),
    // ">" + ">" -> "≫"
    .init(">", ">", CommandBody("\u{226B}", .mathTextContent)),
    // "≪" + "<" -> "⋘"
    .init("\u{226A}", "<", CommandBody("\u{22D8}", .mathTextContent)),
    // "≫" + ">" -> "⋙"
    .init("\u{226B}", ">", CommandBody("\u{22D9}", .mathTextContent)),
    // "~" + "=" -> "≅"
    .init("~", "=", CommandBody("\u{2245}", .mathTextContent)),

    // nodes

    // "$" -> inline-equation
    .init("", "$", CommandBodies.inlineEquation),

    leftRightRule("(", ")"),
    leftRightRule("[", "]"),
    leftRightRule("{", "}"),
    leftRightRule("[", ")"),
    leftRightRule("(", "]"),
    .init("<", ">", CommandBodies.leftRight("\u{27E8}", "\u{27E9}")),
    .init("|", "|", CommandBodies.leftRight("|", "|")),
  ]

  private static func leftRightRule(
    _ left: Character, _ right: Character
  ) -> ReplacementRule {
    let leftStr = String(left)
    return ReplacementRule(leftStr, right, CommandBodies.leftRight(left, right))
  }

}
