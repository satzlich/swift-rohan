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

    // attach
    .init("sub", CommandBodies.subScript),
    .init("sup", CommandBodies.superScript),
    .init("supsub", CommandBodies.supSubScript),
    .init("lrsub", CommandBodies.lrSubScript),

    // accent
    .init("grave", accent(from: Characters.grave)),
    .init("acute", accent(from: Characters.acute)),
    .init("hat", accent(from: Characters.hat)),
    .init("widehat", accent(from: Characters.hat)),
    .init("tilde", accent(from: Characters.tilde)),
    .init("widetilde", accent(from: Characters.tilde)),
    .init("bar", accent(from: Characters.bar)),
    .init("overbar", accent(from: Characters.overbar)),
    .init("wideoverbar", accent(from: Characters.overbar)),
    .init("breve", accent(from: Characters.breve)),
    .init("widebreve", accent(from: Characters.breve)),
    .init("dot", accent(from: Characters.dotAbove)),
    .init("ddot", accent(from: Characters.ddotAbove)),
    .init("ovhook", accent(from: Characters.ovhook)),
    .init("check", accent(from: Characters.check)),
    .init("widecheck", accent(from: Characters.check)),
    .init("vec", accent(from: Characters.rightArrowAbove)),

    // matrix
    .init("pmatrix", matrix(2, 2, DelimiterPair.PAREN)),
    .init("bmatrix", matrix(2, 2, DelimiterPair.BRACKET)),
    .init("Bmatrix", matrix(2, 2, DelimiterPair.BRACE)),
    .init("vmatrix", matrix(2, 2, DelimiterPair.VERT)),
    .init("Vmatrix", matrix(2, 2, DelimiterPair.DOUBLE_VERT)),
  ]

  private static func accent(from char: Character) -> CommandBody {
    let preview = "\(Characters.dottedSquare)\(char)"
    return CommandBody([AccentExpr(char, nucleus: [])], .mathContent, 1, preview)
  }

  private static func matrix(
    _ rowCount: Int, _ columnCount: Int, _ delimiters: DelimiterPair
  ) -> CommandBody {
    let rows: [MatrixExpr.Row] = (0..<rowCount).map { _ in
      let elements: [MatrixExpr.Element] = (0..<columnCount).map { _ in
        MatrixExpr.Element()
      }
      return MatrixExpr.Row(elements)
    }
    let matrix = MatrixExpr(rows, delimiters)
    let n = rowCount * columnCount

    return CommandBody([matrix], .mathContent, n)
  }
}

enum MathCommands {
  static let allCases: [CommandRecord] = [
    .init("frac", [FractionExpr(num: [], denom: [])], .mathContent, 2),
    .init(
      "binom", [FractionExpr(num: [], denom: [], isBinomial: true)],
      .mathContent, 2),
  ]
}
