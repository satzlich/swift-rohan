// Copyright 2024-2025 Lie Yan

/// Non-symbol math commands.
enum MathCommands {
  static let allCases: [CommandRecord] = _allCases()

  private static func _allCases() -> [CommandRecord] {
    var result: [CommandRecord] =
      [
        // attachments
        .init("subscript", Snippets.rSub),
        .init("superscript", Snippets.rSup),
        .init("subsuperscript", Snippets.rSupSub),
        .init("lrsub", Snippets.lrSub),
        // radicals
        .init("sqrt", Snippets.sqrt),
        .init("root", Snippets.root),
        // overline and underline
        .init("overline", Snippets.overline),
        .init("underline", Snippets.underline),
        // `\text`
        .init("text", Snippets.textMode),
      ]

    // accents
    do {
      let records = MathAccent.allCommands.map { accent in
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
      assert(fractions.count == MathGenFrac.allCommands.count)
      let records = fractions.map { frac, image in
        CommandRecord(frac.command, CommandBody.from(frac, image: image))
      }
      result.append(contentsOf: records)
    }

    // left-right
    do {
      let ceil = CommandRecord("ceil", Snippets.leftRight("lceil", "rceil")!)
      let floor = CommandRecord("floor", Snippets.leftRight("lfloor", "rfloor")!)
      let norm = CommandRecord("norm", Snippets.leftRight("Vert", "Vert")!)
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
      assert(matrices.count == MathArray.allCommands.count)

      let records = matrices.map { matrix, image in
        CommandRecord(matrix.command, CommandBody.from(matrix, image: image))
      }
      result.append(contentsOf: records)
    }
    // math expression
    do {
      let expressions: [(MathExpression, CommandBody.CommandPreview)] = [
        // commands
        (MathExpression.bmod, .string("mod")),
        (MathExpression.bot, .string("⊥")),
        (MathExpression.colon, .string(":")),
        (MathExpression.dagger, .string("†")),
        (MathExpression.ddagger, .string("‡")),
        (MathExpression.varDelta, .image("varDelta")),
        (MathExpression.varinjlim, .image("varinjlim")),
        (MathExpression.varliminf, .image("varliminf")),
        (MathExpression.varlimsup, .image("varlimsup")),
        (MathExpression.varprojlim, .image("varprojlim")),
      ]

      let records = expressions.map { (expr, preview) in
        CommandRecord(expr.command, CommandBody.from(expr, preview: preview))
      }
      assert(records.count == MathExpression.allCommands.count)

      result.append(contentsOf: records)
    }
    // math kind
    do {
      let records = MathKind.allCommands.map { kind in
        CommandRecord(kind.command, CommandBody.from(kind))
      }
      result.append(contentsOf: records)
    }

    // math operators
    do {
      let records = MathOperator.allCommands.map { op in
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
      assert(spreaders.count == MathSpreader.allCommands.count)

      let records = spreaders.map { spreader, image in
        CommandRecord(spreader.command, CommandBody.from(spreader, image: image))
      }
      result.append(contentsOf: records)
    }

    do {
      let commands: [(MathTemplate, CommandBody.CommandPreview)] = [
        (MathTemplate.operatorname, .string("⬚")),
        (MathTemplate.pmod, .string("(mod ⬚)")),
        (MathTemplate.stackrel, .image("stackrel")),
        (MathTemplate.xleftarrow, .image("xleftarrow")),
        (MathTemplate.xrightarrow, .image("xrightarrow")),
      ]
      assert(commands.count == MathTemplate.allCommands.count)
      let records = commands.map { (template, preview) in
        CommandRecord(template.command, CommandBody.from(template, preview: preview))
      }
      result.append(contentsOf: records)
    }

    return result
  }
}
