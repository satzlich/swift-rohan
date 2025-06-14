// Copyright 2024-2025 Lie Yan

/// Non-symbol math commands.
enum MathCommands {
  nonisolated(unsafe) static let allCases: Array<CommandRecord> = _allCases()

  private static func _allCases() -> Array<CommandRecord> {
    var result: Array<CommandRecord> = []

    // code snippets
    do {
      let records: Array<CommandRecord> = [
        // attachments
        .init("attachments", Snippets.attachments),
        .init("subscript", Snippets.subscript_),
        .init("superscript", Snippets.superscript),
        .init("subsuperscript", Snippets.subsuperscript),
        // radicals
        .init("root", Snippets.root),
      ]
      result.append(contentsOf: records)

      // left-right
      let abs = CommandRecord("abs", Snippets.leftRight(.pair("lvert", "rvert"))!)
      let ceil = CommandRecord("ceil", Snippets.leftRight(.pair("lceil", "rceil"))!)
      let floor = CommandRecord("floor", Snippets.leftRight(.pair("lfloor", "rfloor"))!)
      let norm = CommandRecord("norm", Snippets.leftRight(.pair("lVert", "rVert"))!)
      result.append(contentsOf: [abs, ceil, floor, norm])
    }

    // miscellaneous
    do {
      let records: Array<CommandRecord> = [
        // radicals
        .init("sqrt", Snippets.sqrt),
        // `\text`
        .init("text", Snippets.textMode),
      ]
      result.append(contentsOf: records)
    }

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

    // matrices
    do {
      let matrices: [(MathArray, String)] =
        [
          (MathArray.aligned, "aligned"),
          (MathArray.cases, "cases"),
          (MathArray.gathered, "gathered"),
          (MathArray.matrix, "matrix"),
          (MathArray.pmatrix, "pmatrix"),
          (MathArray.bmatrix, "bmatrix"),
          (MathArray.Bmatrix, "Bmatrix_"),
          (MathArray.vmatrix, "vmatrix"),
          (MathArray.Vmatrix, "Vmatrix_"),
          (MathArray.substack, "substack"),
        ]
      assert(matrices.count == MathArray.allCommands.count)

      let records = matrices.map { matrix, image in
        CommandRecord(matrix.command, CommandBody.from(matrix, image: image))
      }
      result.append(contentsOf: records)
    }

    // math attributes
    do {
      let records = MathAttributes.allCommands.map { attr in
        CommandRecord(attr.command, CommandBody.from(attr))
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
        (MathExpression.smallint, .string("∫")),
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

    // math operators
    do {
      let records = MathOperator.allCommands.map { op in
        CommandRecord(op.command, CommandBody.from(op))
      }
      result.append(contentsOf: records)
    }

    // math variants
    do {
      let records = MathStyles.allCommands.map { style in
        CommandRecord(style.command, CommandBody.from(style))
      }
      result.append(contentsOf: records)
    }

    // over/under-spreader
    do {
      let spreaders = [
        //
        (MathSpreader.overline, "overline"),
        (MathSpreader.overbrace, "overbrace"),
        (MathSpreader.overbracket, "overbracket"),
        (MathSpreader.overparen, "overparen"),
        //
        (MathSpreader.underline, "underline"),
        (MathSpreader.underbrace, "underbrace"),
        (MathSpreader.underbracket, "underbracket"),
        (MathSpreader.underparen, "underparen"),
        //
        (MathSpreader.xleftarrow, "xleftarrow"),
        (MathSpreader.xrightarrow, "xrightarrow"),
        //
        (MathSpreader.xhookleftarrow, "xhookleftarrow"),
        (MathSpreader.xhookrightarrow, "xhookrightarrow"),
        (MathSpreader.xLeftarrow, "xLeftarrow_"),
        (MathSpreader.xleftharpoondown, "xleftharpoondown"),
        (MathSpreader.xleftharpoonup, "xleftharpoonup"),
        (MathSpreader.xleftrightarrow, "xleftrightarrow"),
        (MathSpreader.xLeftrightarrow, "xLeftrightarrow_"),
        (MathSpreader.xleftrightharpoons, "xleftrightharpoons"),
        (MathSpreader.xmapsto, "xmapsto"),
        (MathSpreader.xRightarrow, "xRightarrow_"),
        (MathSpreader.xrightharpoondown, "xrightharpoondown"),
        (MathSpreader.xrightharpoonup, "xrightharpoonup"),
        (MathSpreader.xrightleftharpoons, "xrightleftharpoons"),
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
        (MathTemplate.overset, .image("overset")),
        (MathTemplate.pmod, .string("(mod ⬚)")),
        (MathTemplate.stackrel, .image("stackrel")),
        (MathTemplate.underset, .image("underset")),
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
