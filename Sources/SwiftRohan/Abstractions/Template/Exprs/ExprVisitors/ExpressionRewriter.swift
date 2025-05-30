// Copyright 2024-2025 Lie Yan

class ExpressionRewriter<C>: ExprVisitor<C, Expr> {
  typealias R = Expr

  /// Convert context before visiting an expression.
  func nextLevelContext(_ node: Expr, _ context: C) -> C {
    context
  }

  override func visit(linebreak: LinebreakExpr, _ context: C) -> Expr {
    linebreak
  }

  override func visit(text: TextExpr, _ context: C) -> R {
    text
  }

  override func visit(unknown: UnknownExpr, _ context: C) -> R {
    unknown
  }

  // MARK: - Template

  override func visit(apply: ApplyExpr, _ context: C) -> R {
    let context = nextLevelContext(apply, context)

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
    let context = nextLevelContext(element, context)
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

  override func visit(root: RootExpr, _ context: C) -> Expr {
    _rewriteElement(root, context)
  }

  override func visit(strong: StrongExpr, _ context: C) -> R {
    _rewriteElement(strong, context)
  }

  // MARK: - Math

  override func visit(accent: AccentExpr, _ context: C) -> R {
    let context = nextLevelContext(accent, context)
    let nucleus = accent.nucleus.accept(self, context) as! ContentExpr
    return accent.with(nucleus: nucleus)
  }

  override func visit(attach: AttachExpr, _ context: C) -> R {
    let context = nextLevelContext(attach, context)

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

  override func visit(equation: EquationExpr, _ context: C) -> R {
    let context = nextLevelContext(equation, context)

    let nucleus = equation.nucleus.accept(self, context) as! ContentExpr
    return equation.with(nucleus: nucleus)
  }

  override func visit(fraction: FractionExpr, _ context: C) -> R {
    let context = nextLevelContext(fraction, context)

    let numerator = fraction.numerator.accept(self, context) as! ContentExpr
    let denominator = fraction.denominator.accept(self, context) as! ContentExpr
    return fraction.with(numerator: numerator).with(denominator: denominator)
  }

  override func visit(leftRight: LeftRightExpr, _ context: C) -> R {
    let context = nextLevelContext(leftRight, context)

    let nucleus = leftRight.nucleus.accept(self, context) as! ContentExpr
    return leftRight.with(nucleus: nucleus)
  }

  override func visit(mathAttributes: MathAttributesExpr, _ context: C) -> Expr {
    let context = nextLevelContext(mathAttributes, context)

    let nucleus = mathAttributes.nucleus.accept(self, context) as! ContentExpr
    return mathAttributes.with(nucleus: nucleus)
  }

  override func visit(mathExpression: MathExpressionExpr, _ context: C) -> R {
    mathExpression
  }

  override func visit(mathOperator: MathOperatorExpr, _ context: C) -> R {
    mathOperator
  }

  override func visit(namedSymbol: NamedSymbolExpr, _ context: C) -> R {
    namedSymbol
  }

  override func visit(mathVariant: MathVariantExpr, _ context: C) -> R {
    let context = nextLevelContext(mathVariant, context)

    let nucleus = mathVariant.nucleus.accept(self, context) as! ContentExpr
    return mathVariant.with(nucleus: nucleus)
  }

  override func visit(matrix: MatrixExpr, _ context: C) -> R {
    let context = nextLevelContext(matrix, context)

    let rows = matrix.rows.map { row in
      let elements = row.map { $0.accept(self, context) as! ContentExpr }
      return MatrixExpr.Row(elements)
    }
    return matrix.with(rows: rows)
  }

  override func visit(overspreader: OverspreaderExpr, _ context: C) -> R {
    let context = nextLevelContext(overspreader, context)

    let nucleus = overspreader.nucleus.accept(self, context) as! ContentExpr
    return overspreader.with(nucleus: nucleus)
  }

  override func visit(radical: RadicalExpr, _ context: C) -> R {
    let context = nextLevelContext(radical, context)

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
    let context = nextLevelContext(textMode, context)

    let nucleus = textMode.nucleus.accept(self, context) as! ContentExpr
    return textMode.with(nucleus: nucleus)
  }

  override func visit(underspreader: UnderspreaderExpr, _ context: C) -> R {
    let context = nextLevelContext(underspreader, context)

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
