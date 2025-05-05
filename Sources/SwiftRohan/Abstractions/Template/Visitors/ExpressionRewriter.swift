// Copyright 2024-2025 Lie Yan

class ExpressionRewriter<C>: ExpressionVisitor<C, Expr> {
  typealias R = Expr

  override func visit(text: TextExpr, _ context: C) -> R {
    text
  }

  override func visit(unknown: UnknownExpr, _ context: C) -> R {
    unknown
  }

  // MARK: - Template

  override func visit(apply: ApplyExpr, _ context: C) -> R {
    let arguments = apply.arguments.map { $0.accept(self, context) as! ContentExpr }
    return apply.with(arguments: arguments)
  }

  override func visit(variable: VariableExpr, _ context: C) -> R {
    variable
  }

  override func visit(cVariable: CompiledVariableExpr, _ context: C) -> R {
    cVariable
  }

  // MARK: - Element

  private func _rewriteElement<T: ElementExpr>(_ element: T, _ context: C) -> T {
    let children = element.children.map { $0.accept(self, context) }
    return element.with(children: children)
  }

  override func visit(content: ContentExpr, _ context: C) -> R {
    _rewriteElement(content, context)
  }

  override func visit(emphasis: EmphasisExpr, _ context: C) -> R {
    _rewriteElement(emphasis, context)
  }

  override func visit(heading: HeadingExpr, _ context: C) -> R {
    _rewriteElement(heading, context)
  }

  override func visit(paragraph: ParagraphExpr, _ context: C) -> R {
    _rewriteElement(paragraph, context)
  }

  override func visit(strong: StrongExpr, _ context: C) -> R {
    _rewriteElement(strong, context)
  }

  // MARK: - Math

  override func visit(accent: AccentExpr, _ context: C) -> R {
    let nucleus = accent.nucleus.accept(self, context) as! ContentExpr
    return accent.with(nucleus: nucleus)
  }

  override func visit(attach: AttachExpr, _ context: C) -> R {
    var result = attach

    attach.lsub.map { lsub in
      let lsub = lsub.accept(self, context) as! ContentExpr
      result = result.with(lsub: lsub)
    }

    attach.lsup.map { lsup in
      let lsup = lsup.accept(self, context) as! ContentExpr
      result = result.with(lsup: lsup)
    }

    do {
      let nucleus = attach.nucleus.accept(self, context) as! ContentExpr
      result = result.with(nucleus: nucleus)
    }

    attach.sub.map { sub in
      let sub = sub.accept(self, context) as! ContentExpr
      result = result.with(sub: sub)
    }

    attach.sup.map { sup in
      let sup = sup.accept(self, context) as! ContentExpr
      result = result.with(sup: sup)
    }

    return result
  }

  override func visit(cases: CasesExpr, _ context: C) -> R {
    let rows = cases.rows.map { row in
      let elements = row.map { $0.accept(self, context) as! ContentExpr }
      return MatrixExpr.Row(elements)
    }
    return cases.with(rows: rows)
  }

  override func visit(equation: EquationExpr, _ context: C) -> R {
    let nucleus = equation.nucleus.accept(self, context) as! ContentExpr
    return equation.with(nucleus: nucleus)
  }

  override func visit(fraction: FractionExpr, _ context: C) -> R {
    let numerator = fraction.numerator.accept(self, context) as! ContentExpr
    let denominator = fraction.denominator.accept(self, context) as! ContentExpr
    return fraction.with(numerator: numerator).with(denominator: denominator)
  }

  override func visit(leftRight: LeftRightExpr, _ context: C) -> R {
    let nucleus = leftRight.nucleus.accept(self, context) as! ContentExpr
    return leftRight.with(nucleus: nucleus)
  }

  override func visit(mathOperator: MathOperatorExpr, _ context: C) -> R {
    let content = _rewriteElement(mathOperator.content, context)
    return mathOperator.with(content: content)
  }

  override func visit(mathVariant: MathVariantExpr, _ context: C) -> R {
    _rewriteElement(mathVariant, context)
  }

  override func visit(matrix: MatrixExpr, _ context: C) -> R {
    let rows = matrix.rows.map { row in
      let elements = row.map { $0.accept(self, context) as! ContentExpr }
      return MatrixExpr.Row(elements)
    }
    return matrix.with(rows: rows)
  }

  override func visit(overline: OverlineExpr, _ context: C) -> R {
    let nucleus = overline.nucleus.accept(self, context) as! ContentExpr
    return overline.with(nucleus: nucleus)
  }

  override func visit(overspreader: OverspreaderExpr, _ context: C) -> R {
    let nucleus = overspreader.nucleus.accept(self, context) as! ContentExpr
    return overspreader.with(nucleus: nucleus)
  }

  override func visit(radical: RadicalExpr, _ context: C) -> R {
    var result = radical

    if let index = radical.index {
      let index = index.accept(self, context) as! ContentExpr
      result = result.with(index: index)
    }
    do {
      let radicand = radical.radicand.accept(self, context) as! ContentExpr
      result = result.with(radicand: radicand)
    }

    return result
  }

  override func visit(textMode: TextModeExpr, _ context: C) -> R {
    let nucleus = textMode.nucleus.accept(self, context) as! ContentExpr
    return textMode.with(nucleus: nucleus)
  }

  override func visit(underline: UnderlineExpr, _ context: C) -> R {
    let nucleus = underline.nucleus.accept(self, context) as! ContentExpr
    return underline.with(nucleus: nucleus)
  }

  override func visit(underspreader: UnderspreaderExpr, _ context: C) -> R {
    let nucleus = underspreader.nucleus.accept(self, context) as! ContentExpr
    return underspreader.with(nucleus: nucleus)
  }

}

extension ExpressionRewriter {
  func rewrite(_ expression: Expr, _ context: C) -> Expr {
    expression.accept(self, context)
  }

  func rewrite(_ expressions: [Expr], _ context: C) -> [Expr] {
    expressions.map { $0.accept(self, context) }
  }
}
