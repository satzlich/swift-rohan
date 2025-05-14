// Copyright 2024-2025 Lie Yan

import Foundation

enum TextCommands {
  static let allCases: [CommandRecord] = [
    // sections
    .init("h1", CommandBodies.header(level: 1)),
    .init("h2", CommandBodies.header(level: 2)),
    .init("h3", CommandBodies.header(level: 3)),
    // style
    .init("emph", CommandBodies.emphasis),
    .init("strong", CommandBodies.strong),
    // math
    .init("equation", CommandBodies.equation),
    .init("inline-equation", CommandBodies.inlineEquation),
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = _allCases()

  private static func _allCases() -> [CommandRecord] {
    var result: [CommandRecord] =
      [

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

        // math variant
        .init("mathbb", CommandBodies.mathVariant(.bb, bold: false, italic: false, "𝔹𝕓")),
        .init(
          "mathcal", CommandBodies.mathVariant(.cal, bold: false, italic: false, "𝒞𝒶𝓁")),
        .init(
          "mathfrak", CommandBodies.mathVariant(.frak, bold: false, italic: false, "𝔉𝔯𝔞𝔨")
        ),
        .init(
          "mathsf", CommandBodies.mathVariant(.sans, bold: false, italic: false, "𝗌𝖺𝗇𝗌")),
        .init(
          "mathrm", CommandBodies.mathVariant(.serif, bold: false, italic: false, "roman")
        ),
        .init(
          "mathbf", CommandBodies.mathVariant(.serif, bold: true, italic: false, "𝐛𝐨𝐥𝐝")),
        .init(
          "mathit", CommandBodies.mathVariant(.serif, bold: false, italic: true, "𝑖𝑡𝑎𝑙𝑖𝑐")
        ),
        .init(
          "mathtt", CommandBodies.mathVariant(.mono, bold: false, italic: false, "𝚖𝚘𝚗𝚘")),

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

    // accents
    do {
      let records = MathAccent.predefinedCases.map { accent in
        CommandRecord(accent.command, CommandBody.from(accent))
      }
      result.append(contentsOf: records)
    }

    // matrices
    do {
      let matrices =
        [
          MathMatrix.matrix,
          MathMatrix.pmatrix,
          MathMatrix.bmatrix,
          MathMatrix.Bmatrix,
          MathMatrix.vmatrix,
          MathMatrix.Vmatrix,
        ]
      let images: [String] = [
        "matrix",
        "pmatrix",
        "bmatrix",
        "Bmatrix_",
        "vmatrix",
        "Vmatrix_",
      ]
      let records = zip(matrices, images).map { matrix, image in
        CommandRecord(matrix.command, CommandBody.from(matrix, image: image))
      }
      result.append(contentsOf: records)
    }

    // math operators
    do {
      let records = MathOperator.predefinedCases.map { op in
        CommandRecord(op.command, CommandBody.from(op))
      }
      result.append(contentsOf: records)
    }
    return result
  }
}
