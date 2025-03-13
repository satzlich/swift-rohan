// Copyright 2024-2025 Lie Yan

class ExpressionRewriter<C>: ExpressionVisitor<C, Expr> {
  typealias R = Expr

  override func visit(text: TextExpr, _ context: C) -> R {
    text
  }

  override func visit(unknown: UnknownExpr, _ context: C) -> Expr {
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

  private func _rewriteElement(_ element: ElementExpr, _ context: C) -> ElementExpr {
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

  // MARK: - Math

  override func visit(equation: EquationExpr, _ context: C) -> R {
    let nuclues = equation.nucleus.accept(self, context) as! ContentExpr
    return equation.with(nucleus: nuclues)
  }

  override func visit(fraction: FractionExpr, _ context: C) -> R {
    let numerator = fraction.numerator.accept(self, context) as! ContentExpr
    let denominator = fraction.denominator.accept(self, context) as! ContentExpr
    return fraction.with(numerator: numerator).with(denominator: denominator)
  }

  override func visit(matrix: MatrixExpr, _ context: C) -> R {
    let rows = matrix.rows.map { row in
      let elements = row.map { $0.accept(self, context) as! ContentExpr }
      return MatrixRow(elements)
    }
    return matrix.with(rows: rows)
  }

  override func visit(scripts: ScriptsExpr, _ context: C) -> R {
    var result = scripts
    if let subScript = scripts.subScript {
      let subScript = subScript.accept(self, context) as! ContentExpr
      result = result.with(subScript: subScript)
    }
    if let superScript = scripts.superScript {
      let superScript = superScript.accept(self, context) as! ContentExpr
      result = result.with(superScript: superScript)
    }
    return result
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
