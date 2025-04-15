// Copyright 2024-2025 Lie Yan

import Foundation

enum TextCommands {
  static let allCases: [CommandRecord] = [
    .init("h1", .topLevelNodes, [HeadingExpr(level: 1, [])], true),
    .init("h2", .topLevelNodes, [HeadingExpr(level: 2, [])], true),
    .init("h3", .topLevelNodes, [HeadingExpr(level: 3, [])], true),
    .init("h4", .topLevelNodes, [HeadingExpr(level: 4, [])], true),
    .init("h5", .topLevelNodes, [HeadingExpr(level: 5, [])], true),
    .init("emph", .inlineContent, [EmphasisExpr([])], true),
    .init("equation", .containsBlock, [EquationExpr(isBlock: true, nucleus: [])], true),
    .init(
      "inline-equation", .inlineContent, [EquationExpr(isBlock: false, nucleus: [])], true
    ),
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = [
    .init("frac", .mathListContent, [FractionExpr(numerator: [], denominator: [])], true)
  ]
}
