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
    // brackets

    // "|" + "|" -> "∥"
    .init("|", "|", CommandBody("\u{2016}", .mathContent)),

    // arrows

    // "<" + "-" -> "←"
    .init("<", "-", CommandBody("\u{2190}", .mathContent)),
    // "-" + ">" -> "→"
    .init("-", ">", CommandBody("\u{2192}", .mathContent)),
    // "=" + ">" -> "⇒"
    .init("=", ">", CommandBody("\u{21D2}", .mathContent)),
    // "--" + ">" -> "⟶"
    .init("--", ">", CommandBody("\u{27F6}", .mathContent)),

    // relations

    // ":" + "=" -> "≔"
    .init(":", "=", CommandBody("\u{2254}", .mathContent)),
    // "=" + ":" -> "≕"
    .init("=", ":", CommandBody("\u{2255}", .mathContent)),
    // "<" + ">" -> "≠"
    .init("<", ">", CommandBody("\u{2260}", .mathContent)),
    // "<" + "=" -> "≤"
    .init("<", "=", CommandBody("\u{2264}", .mathContent)),
    // ">" + "=" -> "≥"
    .init(">", "=", CommandBody("\u{2265}", .mathContent)),
    // "<" + "<" -> "≪"
    .init("<", "<", CommandBody("\u{226A}", .mathContent)),
    // ">" + ">" -> "≫"
    .init(">", ">", CommandBody("\u{226B}", .mathContent)),
    // "≪" + "<" -> "⋘"
    .init("\u{226A}", "<", CommandBody("\u{22D8}", .mathContent)),
    // "≫" + ">" -> "⋙"
    .init("\u{226B}", ">", CommandBody("\u{22D9}", .mathContent)),
    // "~" + "=" -> "≅"
    .init("~", "=", CommandBody("\u{2245}", .mathContent)),
    // nodes

    // "$" -> inline-equation
    .init("", "$", CommandBodies.inlineEquation),
  ]
}
