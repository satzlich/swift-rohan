// Copyright 2024-2025 Lie Yan

import Foundation

enum TextCommands {
  static let allCases: [CommandRecord] = [
    .init("h1", .topLevelNodes, [HeadingExpr(level: 1, [])]),
    .init("h2", .topLevelNodes, [HeadingExpr(level: 2, [])]),
    .init("h3", .topLevelNodes, [HeadingExpr(level: 3, [])]),
    .init("h4", .topLevelNodes, [HeadingExpr(level: 4, [])]),
    .init("h5", .topLevelNodes, [HeadingExpr(level: 5, [])]),
    .init("emph", .inlineContent, [EmphasisExpr([])]),
    .init("equation", .containsBlock, [EquationExpr(isBlock: true, nucleus: [])]),
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = [
    .init("frac", .mathListContent, [FractionExpr(numerator: [], denominator: [])]),
    .init("rightarrow", .mathListContent, [TextExpr("→")]),
  ]
}
