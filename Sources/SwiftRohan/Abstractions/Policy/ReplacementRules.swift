// Copyright 2024-2025 Lie Yan

import Foundation

public enum ReplacementRules {
  public static let allCases: Array<ReplacementRule> = [
    // "`" -> "‘"
    .init("", "`", CommandBody("\u{2018}", .textContent)),
    // "‘" + "`" -> "“"
    .init("\u{2018}", "`", CommandBody("\u{201C}", .textContent)),
    // "'" -> "’"
    .init("", "'", CommandBody("\u{2019}", .textContent)),
    // "’" + "'" -> "”"
    .init("\u{2019}", "'", CommandBody("\u{201D}", .textContent)),
    // "$" -> inline-equation
    .init("", "$", CommandBodies.inlineEquation),
  ]
}
