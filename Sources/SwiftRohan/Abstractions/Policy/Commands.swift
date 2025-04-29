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
    .init("cases", CommandBodies.cases(2, image: "cases")),

    // delimiters
    .init("ceil", CommandBodies.leftRight("\u{2308}", "\u{2309}")),
    .init("floor", CommandBodies.leftRight("\u{230A}", "\u{230B}")),
    .init("norm", CommandBodies.leftRight("\u{2016}", "\u{2016}")),

    // math variant
    .init("mathbb", CommandBodies.mathVariant(.bb, bold: false, italic: false, "𝔹𝕓")),
    .init("mathcal", CommandBodies.mathVariant(.cal, bold: false, italic: false, "𝒞𝒶𝓁")),
    .init(
      "mathfrak", CommandBodies.mathVariant(.frak, bold: false, italic: false, "𝔉𝔯𝔞𝔨")),
    .init("mathsf", CommandBodies.mathVariant(.sans, bold: false, italic: false, "𝗌𝖺𝗇𝗌")),
    .init("mathrm", CommandBodies.mathVariant(.serif, bold: false, italic: false, "roman")),
    .init("mathbf", CommandBodies.mathVariant(.serif, bold: true, italic: false, "𝐛𝐨𝐥𝐝")),
    .init(
      "mathit", CommandBodies.mathVariant(.serif, bold: false, italic: true, "𝑖𝑡𝑎𝑙𝑖𝑐")),
    .init("mathtt", CommandBodies.mathVariant(.mono, bold: false, italic: false, "𝚖𝚘𝚗𝚘")),

    // matrix
    .init("pmatrix", CommandBodies.matrix(2, 2, DelimiterPair.PAREN, image: "pmatrix")),
    .init("bmatrix", CommandBodies.matrix(2, 2, DelimiterPair.BRACKET, image: "bmatrix")),
    .init("Bmatrix", CommandBodies.matrix(2, 2, DelimiterPair.BRACE, image: "Bmatrix_")),
    .init("vmatrix", CommandBodies.matrix(2, 2, DelimiterPair.VERT, image: "vmatrix")),
    .init(
      "Vmatrix", CommandBodies.matrix(2, 2, DelimiterPair.DOUBLE_VERT, image: "Vmatrix_")),

    // under/over
    .init(
      "overline", CommandBody([OverlineExpr([])], .mathContent, 1, image: "overline")),
    .init(
      "underline", CommandBody([UnderlineExpr([])], .mathContent, 1, image: "underline")),
    .init(
      "overbrace", CommandBodies.overSpreader(Characters.overBrace, image: "overbrace")),
    .init(
      "underbrace",
      CommandBodies.underSpreader(Characters.underBrace, image: "underbrace")),
    .init(
      "overbracket",
      CommandBodies.overSpreader(Characters.overBracket, image: "overbracket")),
    .init(
      "underbracket",
      CommandBodies.underSpreader(Characters.underBracket, image: "underbracket")),

    // root
    .init("sqrt", CommandBody([RadicalExpr([])], .mathContent, 1, image: "sqrt")),
    .init("root", CommandBody([RadicalExpr([], [])], .mathContent, 2, image: "root")),
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = [
    .init(
      "frac",
      CommandBody([FractionExpr(num: [], denom: [])], .mathContent, 2, image: "frac")),
    .init(
      "binom",
      CommandBody(
        [FractionExpr(num: [], denom: [], isBinomial: true)], .mathContent, 2,
        image: "binom")),
  ]
}
