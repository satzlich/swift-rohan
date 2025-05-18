// Copyright 2024-2025 Lie Yan

import Foundation

extension Expr {
  func prettyPrint() -> String {
    let visitor = PrettyPrintVisitor()
    let lines = accept(visitor, ())
    return lines.joined(separator: "\n")
  }
}

private final class PrettyPrintVisitor: ExprVisitor<Void, Array<String>> {
  // MARK: - Template

  override func visit(apply: ApplyExpr, _ context: Void) -> Array<String> {
    let description = "\(apply.type) \"\(apply.templateName)\""
    let children = apply.arguments.map { $0.accept(self, context) }
    return PrintUtils.compose([description], children)
  }

  override func visit(variable: VariableExpr, _ context: Void) -> Array<String> {
    let description = "\(variable.type) \"\(variable.name)\""
    return PrintUtils.compose([description], [])
  }

  override func visit(cVariable: CompiledVariableExpr, _ context: Void) -> Array<String> {
    let description = "\(cVariable.type) #\(cVariable.argumentIndex)"
    return PrintUtils.compose([description], [])
  }

  // MARK: - Elements

  private final func _visitElement<T: ElementExpr>(
    _ element: T, _ context: Void, _ description: Array<String>? = nil
  ) -> Array<String> {
    let description = description ?? ["\(element.type)"]
    let children = element.children.map { $0.accept(self, context) }
    return PrintUtils.compose(description, children)
  }

  override func visit(content: ContentExpr, _ context: Void) -> Array<String> {
    _visitElement(content, context)
  }

  override func visit(emphasis: EmphasisExpr, _ context: Void) -> Array<String> {
    _visitElement(emphasis, context)
  }

  override func visit(heading: HeadingExpr, _ context: Void) -> Array<String> {
    let description = "\(heading.type) level: \(heading.level)"
    return _visitElement(heading, context, [description])
  }

  override func visit(paragraph: ParagraphExpr, _ context: Void) -> Array<String> {
    _visitElement(paragraph, context)
  }

  override func visit(root: RootExpr, _ context: Void) -> Array<String> {
    _visitElement(root, context)
  }

  override func visit(strong: StrongExpr, _ context: Void) -> Array<String> {
    _visitElement(strong, context)
  }

  // MARK: - Math

  private final func _visitMath<T: MathExpr>(
    _ math: T, _ context: Void, _ description: Array<String>? = nil
  ) -> Array<String> {
    let description = description ?? ["\(math.type)"]
    let components = math.enumerateComponents()
    let children = components.map { index, component in
      let description = ["\(index)"]
      return _visitElement(component, context, description)
    }
    return PrintUtils.compose(description, children)
  }

  private final func _visitRow(
    _ row: GridRow<ContentExpr>, _ context: Void, _ description: Array<String>
  ) -> Array<String> {
    let children: [Array<String>] = row.map { $0.accept(self, context) }
    return PrintUtils.compose(description, children)
  }

  override func visit(accent: AccentExpr, _ context: Void) -> Array<String> {
    let description = "\(accent.type) accent: \(accent.accent)"
    return _visitMath(accent, context, [description])
  }

  override func visit(aligned: AlignedExpr, _ context: Void) -> Array<String> {
    let description = "\(aligned.type)"
    let rows: [Array<String>] = aligned.rows.enumerated().map { (i, row) in
      let description = "row \(i)"
      return _visitRow(row, context, [description])
    }
    return PrintUtils.compose([description], rows)
  }

  override func visit(attach: AttachExpr, _ context: Void) -> Array<String> {
    _visitMath(attach, context)
  }

  override func visit(cases: CasesExpr, _ context: Void) -> Array<String> {
    let description = "\(cases.type)"
    let rows: [Array<String>] = cases.rows.enumerated().map { (i, row) in
      let description = "row \(i)"
      return _visitRow(row, context, [description])
    }
    return PrintUtils.compose([description], rows)
  }

  override func visit(equation: EquationExpr, _ context: Void) -> Array<String> {
    let description = "\(equation.type) \(equation.subtype)"
    return _visitMath(equation, context, [description])
  }

  override func visit(fraction: FractionExpr, _ context: Void) -> Array<String> {
    let description = "\(fraction.type) subtype: \(fraction.subtype)"
    return _visitMath(fraction, context, [description])
  }

  override func visit(leftRight: LeftRightExpr, _ context: Void) -> Array<String> {
    _visitMath(leftRight, context)
  }

  override func visit(
    mathExpression: MathExpressionExpr, _ context: Void
  ) -> Array<String> {
    let description = "\(mathExpression.type) \(mathExpression.mathExpression.command)"
    return PrintUtils.compose([description], [])
  }

  override func visit(mathKind: MathKindExpr, _ context: Void) -> Array<String> {
    return _visitMath(mathKind, context)
  }

  override func visit(mathOperator: MathOperatorExpr, _ context: Void) -> Array<String> {
    let description = "\(mathOperator.type) \(mathOperator.mathOp.command)"
    return PrintUtils.compose([description], [])
  }

  override func visit(mathSymbol: MathSymbolExpr, _ context: Void) -> Array<String> {
    let description = "\(mathSymbol.type) \(mathSymbol.mathSymbol.command)"
    return PrintUtils.compose([description], [])
  }

  override func visit(mathVariant: MathVariantExpr, _ context: Void) -> Array<String> {
    _visitMath(mathVariant, context)
  }

  override func visit(matrix: MatrixExpr, _ context: Void) -> Array<String> {
    let description = "\(matrix.type) \(matrix.rowCount)x\(matrix.columnCount)"
    let rows: [Array<String>] = matrix.rows.enumerated().map { (i, row) in
      let description = "row \(i)"
      return _visitRow(row, context, [description])
    }
    return PrintUtils.compose([description], rows)
  }

  override func visit(overline: OverlineExpr, _ context: Void) -> Array<String> {
    _visitMath(overline, context)
  }

  override func visit(overspreader: OverspreaderExpr, _ context: Void) -> Array<String> {
    _visitMath(overspreader, context)
  }

  override func visit(radical: RadicalExpr, _ context: Void) -> Array<String> {
    _visitMath(radical, context)
  }

  override func visit(textMode: TextModeExpr, _ context: Void) -> Array<String> {
    _visitMath(textMode, context)
  }

  override func visit(underline: UnderlineExpr, _ context: Void) -> Array<String> {
    _visitMath(underline, context)
  }

  override func visit(underspreader: UnderspreaderExpr, _ context: Void) -> Array<String>
  {
    _visitMath(underspreader, context)
  }

  // MARK: - Misc

  override func visit(linebreak: LinebreakExpr, _ context: Void) -> Array<String> {
    let description = "\(linebreak.type)"
    return PrintUtils.compose([description], [])
  }

  override func visit(text: TextExpr, _ context: Void) -> Array<String> {
    let description = "\(text.type) \"\(text.string)\""
    return PrintUtils.compose([description], [])
  }

  override func visit(unknown: UnknownExpr, _ context: Void) -> Array<String> {
    let description = "\(unknown.type)"
    return PrintUtils.compose([description], [])
  }
}
