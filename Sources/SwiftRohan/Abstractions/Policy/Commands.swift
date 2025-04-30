// Copyright 2024-2025 Lie Yan

import Foundation

enum TextCommands {
  static let allCases: [CommandRecord] = [
    .init("emph", CommandBodies.emphasis),
    .init("equation", CommandBodies.equation),
    .init("h1", CommandBodies.header(level: 1)),
    .init("h2", CommandBodies.header(level: 2)),
    .init("h3", CommandBodies.header(level: 3)),
    .init("h4", CommandBodies.header(level: 4)),
    .init("h5", CommandBodies.header(level: 5)),
    .init("h6", CommandBodies.header(level: 6)),
    .init("inline-equation", CommandBodies.inlineEquation),
    .init("strong", CommandBodies.strong),
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = [

    // attach
    .init("subscript", CommandBodies.subScript),
    .init("supscript", CommandBodies.superScript),
    .init("supsubscript", CommandBodies.supSubScript),
    .init("lrsubscript", CommandBodies.lrSubScript),

    // accent
    .init("grave", CommandBodies.accent(Characters.grave)),
    .init("acute", CommandBodies.accent(Characters.acute)),
    .init("hat", CommandBodies.accent(Characters.hat)),
    .init("widehat", CommandBodies.accent(Characters.hat)),
    .init("tilde", CommandBodies.accent(Characters.tilde)),
    .init("widetilde", CommandBodies.accent(Characters.tilde)),
    .init("bar", CommandBodies.accent(Characters.bar)),
    .init("overbar", CommandBodies.accent(Characters.overbar)),
    .init("wideoverbar", CommandBodies.accent(Characters.overbar)),
    .init("breve", CommandBodies.accent(Characters.breve)),
    .init("widebreve", CommandBodies.accent(Characters.breve)),
    .init("dot", CommandBodies.accent(Characters.dotAbove)),
    .init("ddot", CommandBodies.accent(Characters.ddotAbove)),
    .init("ovhook", CommandBodies.accent(Characters.ovhook)),
    .init("check", CommandBodies.accent(Characters.check)),
    .init("widecheck", CommandBodies.accent(Characters.check)),
    .init("vec", CommandBodies.accent(Characters.rightArrowAbove)),

    // cases
    .init("cases", CommandBodies.cases(2, image: "cases")),

    // delimiters
    .init("ceil", CommandBodies.leftRight("\u{2308}", "\u{2309}")),
    .init("floor", CommandBodies.leftRight("\u{230A}", "\u{230B}")),
    .init("norm", CommandBodies.leftRight("\u{2016}", "\u{2016}")),

    // generalised fraction
    .init("binom", CommandBodies.binom),
    .init("frac", CommandBodies.frac),

    // math operator
    /*
     arccos, arcsin, arctan, arg, cos, cosh, cot, coth, csc, csch, ctg, deg, det, dim,
     exp, gcd, lcm, hom, id, im, inf, ker, lg, lim, liminf, limsup, ln, log, max, min,
     mod, Pr, sec, sech, sin, sinc, sinh, sup, tan, tanh, tg and tr.
     */
    .init("arccos", CommandBodies.mathOperator("arccos")),
    .init("arcsin", CommandBodies.mathOperator("arcsin")),
    .init("arctan", CommandBodies.mathOperator("arctan")),
    .init("arg", CommandBodies.mathOperator("arg")),
    .init("cos", CommandBodies.mathOperator("cos")),
    .init("cosh", CommandBodies.mathOperator("cosh")),
    .init("cot", CommandBodies.mathOperator("cot")),
    .init("coth", CommandBodies.mathOperator("coth")),
    .init("csc", CommandBodies.mathOperator("csc")),
    .init("csch", CommandBodies.mathOperator("csch")),
    .init("ctg", CommandBodies.mathOperator("ctg")),
    .init("deg", CommandBodies.mathOperator("deg")),
    .init("det", CommandBodies.mathOperator("det")),
    .init("dim", CommandBodies.mathOperator("dim")),
    .init("exp", CommandBodies.mathOperator("exp")),
    .init("gcd", CommandBodies.mathOperator("gcd")),
    .init("lcm", CommandBodies.mathOperator("lcm")),
    .init("hom", CommandBodies.mathOperator("hom")),
    .init("id", CommandBodies.mathOperator("id")),
    .init("im", CommandBodies.mathOperator("im")),
    .init("inf", CommandBodies.mathOperator("inf", true)),
    .init("ker", CommandBodies.mathOperator("ker")),
    .init("lg", CommandBodies.mathOperator("lg")),
    .init("lim", CommandBodies.mathOperator("lim", true)),
    .init("liminf", CommandBodies.mathOperator("lim\u{2009}inf", true)),
    .init("limsup", CommandBodies.mathOperator("lim\u{2009}sup", true)),
    .init("ln", CommandBodies.mathOperator("ln")),
    .init("log", CommandBodies.mathOperator("log")),
    .init("max", CommandBodies.mathOperator("max", true)),
    .init("min", CommandBodies.mathOperator("min", true)),
    .init("mod", CommandBodies.mathOperator("mod")),
    .init("Pr", CommandBodies.mathOperator("Pr")),
    .init("sec", CommandBodies.mathOperator("sec")),
    .init("sech", CommandBodies.mathOperator("sech")),
    .init("sin", CommandBodies.mathOperator("sin")),
    .init("sinc", CommandBodies.mathOperator("sinc")),
    .init("sinh", CommandBodies.mathOperator("sinh")),
    .init("sup", CommandBodies.mathOperator("sup", true)),
    .init("tan", CommandBodies.mathOperator("tan")),
    .init("tanh", CommandBodies.mathOperator("tanh")),
    .init("tg", CommandBodies.mathOperator("tg")),
    .init("tr", CommandBodies.mathOperator("tr")),

    // math variant
    .init("mathbb", CommandBodies.mathVariant(.bb, bold: false, italic: false, "𝔹𝕓")),
    .init("mathcal", CommandBodies.mathVariant(.cal, bold: false, italic: false, "𝒞𝒶𝓁")),
    .init(
      "mathfrak", CommandBodies.mathVariant(.frak, bold: false, italic: false, "𝔉𝔯𝔞𝔨")),
    .init("mathsf", CommandBodies.mathVariant(.sans, bold: false, italic: false, "𝗌𝖺𝗇𝗌")),
    .init(
      "mathrm", CommandBodies.mathVariant(.serif, bold: false, italic: false, "roman")),
    .init("mathbf", CommandBodies.mathVariant(.serif, bold: true, italic: false, "𝐛𝐨𝐥𝐝")),
    .init(
      "mathit", CommandBodies.mathVariant(.serif, bold: false, italic: true, "𝑖𝑡𝑎𝑙𝑖𝑐")),
    .init("mathtt", CommandBodies.mathVariant(.mono, bold: false, italic: false, "𝚖𝚘𝚗𝚘")),

    // matrix
    .init("pmatrix", CommandBodies.matrix(2, 1, DelimiterPair.PAREN, image: "pmatrix")),
    .init("bmatrix", CommandBodies.matrix(2, 1, DelimiterPair.BRACKET, image: "bmatrix")),
    .init("Bmatrix", CommandBodies.matrix(2, 2, DelimiterPair.BRACE, image: "Bmatrix_")),
    .init("vmatrix", CommandBodies.matrix(2, 2, DelimiterPair.VERT, image: "vmatrix")),
    .init(
      "Vmatrix", CommandBodies.matrix(2, 2, DelimiterPair.DOUBLE_VERT, image: "Vmatrix_")),

    // under/over
    .init("overline", CommandBodies.overline),
    .init("underline", CommandBodies.underline),
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
    .init("sqrt", CommandBodies.sqrt),
    .init("root", CommandBodies.root),
  ]
}
