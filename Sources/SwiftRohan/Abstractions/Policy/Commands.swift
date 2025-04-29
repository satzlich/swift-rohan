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
    .init("grave", CommandBodies.accent(from: Characters.grave)),
    .init("acute", CommandBodies.accent(from: Characters.acute)),
    .init("hat", CommandBodies.accent(from: Characters.hat)),
    .init("widehat", CommandBodies.accent(from: Characters.hat)),
    .init("tilde", CommandBodies.accent(from: Characters.tilde)),
    .init("widetilde", CommandBodies.accent(from: Characters.tilde)),
    .init("bar", CommandBodies.accent(from: Characters.bar)),
    .init("overbar", CommandBodies.accent(from: Characters.overbar)),
    .init("wideoverbar", CommandBodies.accent(from: Characters.overbar)),
    .init("breve", CommandBodies.accent(from: Characters.breve)),
    .init("widebreve", CommandBodies.accent(from: Characters.breve)),
    .init("dot", CommandBodies.accent(from: Characters.dotAbove)),
    .init("ddot", CommandBodies.accent(from: Characters.ddotAbove)),
    .init("ovhook", CommandBodies.accent(from: Characters.ovhook)),
    .init("check", CommandBodies.accent(from: Characters.check)),
    .init("widecheck", CommandBodies.accent(from: Characters.check)),
    .init("vec", CommandBodies.accent(from: Characters.rightArrowAbove)),

    // cases
    .init("cases", CommandBodies.cases(2)),

    // delimiters
    .init("ceil", CommandBodies.leftRight("\u{2308}", "\u{2309}")),
    .init("floor", CommandBodies.leftRight("\u{230A}", "\u{230B}")),
    .init("norm", CommandBodies.leftRight("\u{2016}", "\u{2016}")),

    // math variant
    .init("mathbb", CommandBodies.mathVariant(.bb, bold: false, italic: false)),
    .init("mathcal", CommandBodies.mathVariant(.cal, bold: false, italic: false)),
    .init("mathfrak", CommandBodies.mathVariant(.frak, bold: false, italic: false)),
    .init("mathsf", CommandBodies.mathVariant(.sans, bold: false, italic: false)),
    .init("mathrm", CommandBodies.mathVariant(.serif, bold: false, italic: false)),
    .init("mathbf", CommandBodies.mathVariant(.serif, bold: true, italic: false)),
    .init("mathit", CommandBodies.mathVariant(.serif, bold: false, italic: true)),
    .init("mathtt", CommandBodies.mathVariant(.mono, bold: false, italic: false)),

    // matrix
    .init("pmatrix", CommandBodies.matrix(2, 2, DelimiterPair.PAREN)),
    .init("bmatrix", CommandBodies.matrix(2, 2, DelimiterPair.BRACKET)),
    .init("Bmatrix", CommandBodies.matrix(2, 2, DelimiterPair.BRACE)),
    .init("vmatrix", CommandBodies.matrix(2, 2, DelimiterPair.VERT)),
    .init("Vmatrix", CommandBodies.matrix(2, 2, DelimiterPair.DOUBLE_VERT)),

    // under/over
    .init(
      "overline", CommandBody([OverlineExpr([])], .mathContent, 1, "\u{2B1A}\u{0305}")),
    .init(
      "underline", CommandBody([UnderlineExpr([])], .mathContent, 1, "\u{2B1A}\u{0332}")),
    .init(
      "overbrace", CommandBodies.overSpreader(Characters.overBrace, image: "overbrace")),
    .init("underbrace", CommandBodies.underSpreader(Characters.underBrace)),
    .init("overbracket", CommandBodies.overSpreader(Characters.overBracket)),
    .init("underbracket", CommandBodies.underSpreader(Characters.underBracket)),

    // root
    .init("sqrt", CommandBody([RadicalExpr([])], .mathContent, 1)),
    .init("root", CommandBody([RadicalExpr([], [])], .mathContent, 2)),
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
