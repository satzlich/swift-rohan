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
  ]
}

enum MathCommands {
  static let allCases: [CommandRecord] = _allCases()

  private static func _allCases() -> [CommandRecord] {
    var result: [CommandRecord] =
      [
        // attachments
        .init("lrsubscript", CommandBodies.lrSubScript),
        // radicals
        .init("sqrt", CommandBodies.sqrt),
        .init("root", CommandBodies.root),
        // overline and underline
        .init("overline", CommandBodies.overline),
        .init("underline", CommandBodies.underline),
        // `\text`
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
        (MathGenFrac.cfrac, "frac"),
        (MathGenFrac.dfrac, "frac"),
        (MathGenFrac.tfrac, "frac"),
        (MathGenFrac.binom, "binom"),
        (MathGenFrac.dbinom, "dbinom"),
        (MathGenFrac.tbinom, "tbinom"),
        (MathGenFrac.atop, "atop"),
      ]
      assert(fractions.count == MathGenFrac.predefinedCases.count)
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
          (MathArray.aligned, "aligned"),
          (MathArray.cases, "cases"),
          (MathArray.matrix, "matrix"),
          (MathArray.pmatrix, "pmatrix"),
          (MathArray.bmatrix, "bmatrix"),
          (MathArray.Bmatrix, "Bmatrix_"),
          (MathArray.vmatrix, "vmatrix"),
          (MathArray.Vmatrix, "Vmatrix_"),
        ]
      assert(matrices.count == MathArray.predefinedCases.count)

      let records = matrices.map { matrix, image in
        CommandRecord(matrix.command, CommandBody.from(matrix, image: image))
      }
      result.append(contentsOf: records)
    }
    // math expression
    do {
      let expressions: [(MathExpression, CommandBody.CommandPreview)] = [
        (MathExpression.colon, .string(":")),
        (MathExpression.varDelta, .image("varDelta")),
      ]

      let records = expressions.map { (expr, preview) in
        CommandRecord(expr.command, CommandBody.from(expr, preview: preview))
      }
      assert(records.count == MathExpression.predefinedCases.count)

      result.append(contentsOf: records)
    }
    // math kind
    do {
      let records = MathKind.predefinedCases.map { kind in
        CommandRecord(kind.command, CommandBody.from(kind))
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

    // over/under-spreader
    do {
      let spreaders = [
        (MathSpreader.overbrace, "overbrace"),
        (MathSpreader.overbracket, "overbracket"),
        (MathSpreader.overparen, "overparen"),
        (MathSpreader.underbrace, "underbrace"),
        (MathSpreader.underbracket, "underbracket"),
        (MathSpreader.underparen, "underparen"),
      ]
      assert(spreaders.count == MathSpreader.predefinedCases.count)

      let records = spreaders.map { spreader, image in
        CommandRecord(spreader.command, CommandBody.from(spreader, image: image))
      }
      result.append(contentsOf: records)
    }

    return result
  }
}
