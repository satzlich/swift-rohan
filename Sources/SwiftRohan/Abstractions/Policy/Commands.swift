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
    .init("inline-equation", CommandBodies.inlineEquation),
    .init("strong", CommandBodies.strong),
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = [
    // accent
    .init("grave", CommandBodies.accent(Chars.grave)),
    .init("acute", CommandBodies.accent(Chars.acute)),
    .init("hat", CommandBodies.accent(Chars.hat)),
    .init("widehat", CommandBodies.accent(Chars.hat)),
    .init("tilde", CommandBodies.accent(Chars.tilde)),
    .init("widetilde", CommandBodies.accent(Chars.tilde)),
    .init("bar", CommandBodies.accent(Chars.bar)),
    .init("overbar", CommandBodies.accent(Chars.overbar)),
    .init("wideoverbar", CommandBodies.accent(Chars.overbar)),
    .init("breve", CommandBodies.accent(Chars.breve)),
    .init("widebreve", CommandBodies.accent(Chars.breve)),
    .init("dot", CommandBodies.accent(Chars.dotAbove)),
    .init("ddot", CommandBodies.accent(Chars.ddotAbove)),
    .init("ovhook", CommandBodies.accent(Chars.ovhook)),
    .init("check", CommandBodies.accent(Chars.check)),
    .init("widecheck", CommandBodies.accent(Chars.check)),
    .init("vec", CommandBodies.accent(Chars.rightArrowAbove)),

    // aligned
    .init("aligned", CommandBodies.aligned(2, 2, image: "aligned")),

    // attach
    .init("lrsubscript", CommandBodies.lrSubScript),

    // cases
    .init("cases", CommandBodies.cases(2, image: "cases")),

    // delimiters
    .init("ceil", CommandBodies.leftRight("\u{2308}", "\u{2309}")),
    .init("floor", CommandBodies.leftRight("\u{230A}", "\u{230B}")),
    .init("norm", CommandBodies.leftRight("\u{2016}", "\u{2016}")),

    // generalised fraction
    .init("atop", CommandBodies.genfrac(.atop, image: "atop")),
    .init("binom", CommandBodies.genfrac(.binom, image: "binom")),
    .init("frac", CommandBodies.genfrac(.frac, image: "frac")),
    .init("dfrac", CommandBodies.genfrac(.dfrac, image: "frac")),
    .init("tfrac", CommandBodies.genfrac(.tfrac, image: "frac")),

    // math operator
    .init("arccos", MathOperators.arccos),
    .init("arcsin", MathOperators.arcsin),
    .init("arctan", MathOperators.arctan),
    .init("arg", MathOperators.arg),
    .init("cos", MathOperators.cos),
    .init("cosh", MathOperators.cosh),
    .init("cot", MathOperators.cot),
    .init("coth", MathOperators.coth),
    .init("csc", MathOperators.csc),
    .init("csch", MathOperators.csch),
    .init("ctg", MathOperators.ctg),
    .init("deg", MathOperators.deg),
    .init("det", MathOperators.det),
    .init("dim", MathOperators.dim),
    .init("exp", MathOperators.exp),
    .init("gcd", MathOperators.gcd),
    .init("lcm", MathOperators.lcm),
    .init("hom", MathOperators.hom),
    .init("id", MathOperators.id),
    .init("im", MathOperators.im),
    .init("inf", MathOperators.inf),
    .init("ker", MathOperators.ker),
    .init("lg", MathOperators.lg),
    .init("lim", MathOperators.lim),
    .init("liminf", MathOperators.liminf),
    .init("limsup", MathOperators.limsup),
    .init("ln", MathOperators.ln),
    .init("log", MathOperators.log),
    .init("max", MathOperators.max),
    .init("min", MathOperators.min),
    .init("mod", MathOperators.mod),
    .init("Pr", MathOperators.Pr),
    .init("sec", MathOperators.sec),
    .init("sech", MathOperators.sech),
    .init("sin", MathOperators.sin),
    .init("sinc", MathOperators.sinc),
    .init("sinh", MathOperators.sinh),
    .init("sup", MathOperators.sup),
    .init("tan", MathOperators.tan),
    .init("tanh", MathOperators.tanh),
    .init("tg", MathOperators.tg),
    .init("tr", MathOperators.tr),

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
    .init("matrix", CommandBodies.matrix(2, 2, DelimiterPair.NONE, image: "matrix")),
    .init("pmatrix", CommandBodies.matrix(2, 2, DelimiterPair.PAREN, image: "pmatrix")),
    .init("bmatrix", CommandBodies.matrix(2, 2, DelimiterPair.BRACKET, image: "bmatrix")),
    .init("Bmatrix", CommandBodies.matrix(2, 2, DelimiterPair.BRACE, image: "Bmatrix_")),
    .init("vmatrix", CommandBodies.matrix(2, 2, DelimiterPair.VERT, image: "vmatrix")),
    .init(
      "Vmatrix", CommandBodies.matrix(2, 2, DelimiterPair.DOUBLE_VERT, image: "Vmatrix_")),

    // root
    .init("sqrt", CommandBodies.sqrt),
    .init("root", CommandBodies.root),

    // under/over
    .init("overline", CommandBodies.overline),
    .init("underline", CommandBodies.underline),
    .init(
      "overbrace", CommandBodies.overSpreader(Chars.overBrace, image: "overbrace")),
    .init(
      "underbrace",
      CommandBodies.underSpreader(Chars.underBrace, image: "underbrace")),
    .init(
      "overbracket",
      CommandBodies.overSpreader(Chars.overBracket, image: "overbracket")),
    .init(
      "underbracket",
      CommandBodies.underSpreader(Chars.underBracket, image: "underbracket")),

    // text
    .init("text", CommandBodies.textMode),
  ]
}
