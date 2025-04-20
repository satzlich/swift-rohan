// Copyright 2024-2025 Lie Yan

import Foundation

enum TextCommands {
  static let allCases: [CommandRecord] = [
    .init("h1", .topLevelNodes, [HeadingExpr(level: 1, [])], 1),
    .init("h2", .topLevelNodes, [HeadingExpr(level: 2, [])], 1),
    .init("h3", .topLevelNodes, [HeadingExpr(level: 3, [])], 1),
    .init("h4", .topLevelNodes, [HeadingExpr(level: 4, [])], 1),
    .init("h5", .topLevelNodes, [HeadingExpr(level: 5, [])], 1),
    .init("h6", .topLevelNodes, [HeadingExpr(level: 6, [])], 1),
    .init("emph", .inlineContent, [EmphasisExpr([])], 1),
    .init("equation", .containsBlock, [EquationExpr(isBlock: true, nucleus: [])], 1),
    .init(
      "inline-equation", .inlineContent, [EquationExpr(isBlock: false, nucleus: [])], 1),
    .init("strong", .inlineContent, [StrongExpr([])], 1),
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = [
    .init("frac", .mathListContent, [FractionExpr(numerator: [], denominator: [])], 2),
    .init(
      "binom", .mathListContent,
      [FractionExpr(numerator: [], denominator: [], isBinomial: true)], 2),
  ]
}
