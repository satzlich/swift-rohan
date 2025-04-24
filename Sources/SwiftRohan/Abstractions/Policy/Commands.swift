// Copyright 2024-2025 Lie Yan

import Foundation

enum TextCommands {
  static let allCases: [CommandRecord] = [
    .init("h1", [HeadingExpr(level: 1, [])], .topLevelNodes, 1),
    .init("h2", [HeadingExpr(level: 2, [])], .topLevelNodes, 1),
    .init("h3", [HeadingExpr(level: 3, [])], .topLevelNodes, 1),
    .init("h4", [HeadingExpr(level: 4, [])], .topLevelNodes, 1),
    .init("h5", [HeadingExpr(level: 5, [])], .topLevelNodes, 1),
    .init("h6", [HeadingExpr(level: 6, [])], .topLevelNodes, 1),
    .init("emph", [EmphasisExpr([])], .inlineContent, 1),
    .init("equation", [EquationExpr(isBlock: true, nuc: [])], .containsBlock, 1),
    .init("inline-equation", CommandBodies.inlineEquation),
    .init("strong", [StrongExpr([])], .inlineContent, 1),
    .init("sub", CommandBodies.subScript),
    .init("sup", CommandBodies.superScript),
    .init("supsub", CommandBodies.supSubScript),
    .init("lrsub", CommandBodies.lrSubScript),
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = [
    .init("frac", [FractionExpr(num: [], denom: [])], .mathContent, 2),
    .init(
      "binom", [FractionExpr(num: [], denom: [], isBinomial: true)],
      .mathContent, 2),
  ]
}
