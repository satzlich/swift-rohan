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
        // root
        .init("sqrt", CommandBodies.sqrt),
        .init("root", CommandBodies.root),
        // under/over
        .init("overline", CommandBodies.overline),
        .init("underline", CommandBodies.underline),
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

    // generic fractions
    do {
      let fractions = [
        (MathGenFrac.frac, "frac"),
        (MathGenFrac.dfrac, "frac"),
        (MathGenFrac.tfrac, "frac"),
        (MathGenFrac.binom, "binom"),
        (MathGenFrac.atop, "atop"),
      ]
      let records = fractions.map { frac, image in
        CommandRecord(frac.command, CommandBody.from(frac, image: image))
      }
      result.append(contentsOf: records)
    }

    // left-right
    do {
      let ceil = CommandRecord("ceil", CommandBodies.leftRight("lceil", "rceil")!)
      let floor = CommandRecord("floor", CommandBodies.leftRight("lfloor", "rfloor")!)
      let norm = CommandRecord("norm", CommandBodies.leftRight("Vert", "Vert")!)
      result.append(contentsOf: [ceil, floor, norm])
    }

    // matrices
    do {
      let matrices: [(MathArray, String)] =
        [
          (MathArray.matrix, "matrix"),
          (MathArray.pmatrix, "pmatrix"),
          (MathArray.bmatrix, "bmatrix"),
          (MathArray.Bmatrix, "Bmatrix_"),
          (MathArray.vmatrix, "vmatrix"),
          (MathArray.Vmatrix, "Vmatrix_"),
        ]
      let records = matrices.map { matrix, image in
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

    // math variants
    do {
      let records = MathTextStyle.allCases.map { style in
        CommandRecord(style.command, CommandBody.from(style))
      }
      result.append(contentsOf: records)
    }

    // under/over
    do {
      let unders = [
        (MathUnderSpreader.underbrace, "underbrace"),
        (MathUnderSpreader.underbracket, "underbracket"),
      ]

      let overs = [
        (MathOverSpreader.overbrace, "overbrace"),
        (MathOverSpreader.overbracket, "overbracket"),
      ]

      let underRecords = unders.map { spreader, image in
        CommandRecord(spreader.command, CommandBody.from(spreader, image: image))
      }
      result.append(contentsOf: underRecords)

      let overRecords = overs.map { spreader, image in
        CommandRecord(spreader.command, CommandBody.from(spreader, image: image))
      }
      result.append(contentsOf: overRecords)
    }

    return result
  }
}
