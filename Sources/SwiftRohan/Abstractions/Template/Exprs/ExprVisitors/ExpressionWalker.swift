import Foundation

class ExpressionWalker<C>: ExprVisitor<C, Void> {
  func willVisitExpression(_ expression: Expr, _ context: C) -> Void {}
  func didVisitExpression(_ expression: Expr, _ context: C) -> Void {}

  override func visitExpr(_ expression: Expr, _ context: C) -> Void {
    assertionFailure("visitExpr should not be called directly")
  }

  override func visit(counter: CounterExpr, _ context: C) -> Void {
    willVisitExpression(counter, context)
    do { didVisitExpression(counter, context) }
  }

  override func visit(linebreak: LinebreakExpr, _ context: C) -> Void {
    willVisitExpression(linebreak, context)
    do { didVisitExpression(linebreak, context) }
  }

  override func visit(text: TextExpr, _ context: C) -> Void {
    willVisitExpression(text, context)
    do { didVisitExpression(text, context) }
  }

  override func visit(unknown: UnknownExpr, _ context: C) -> Void {
    willVisitExpression(unknown, context)
    do { didVisitExpression(unknown, context) }
  }

  // MARK: - Template

  override func visit(apply: ApplyExpr, _ context: C) -> Void {
    willVisitExpression(apply, context)
    defer { didVisitExpression(apply, context) }
    apply.arguments.forEach { $0.accept(self, context) }
  }

  override func visit(variable: VariableExpr, _ context: C) -> Void {
    willVisitExpression(variable, context)
    do { didVisitExpression(variable, context) }
  }

  override func visit(cVariable: CompiledVariableExpr, _ context: C) -> Void {
    willVisitExpression(cVariable, context)
    do { didVisitExpression(cVariable, context) }
  }

  // MARK: - Element

  private func _visitElement<T: ElementExpr>(_ element: T, _ context: C) {
    willVisitExpression(element, context)
    defer { didVisitExpression(element, context) }
    element.children.forEach { $0.accept(self, context) }
  }

  override func visit(content: ContentExpr, _ context: C) -> Void {
    _visitElement(content, context)
  }

  override func visit(heading: HeadingExpr, _ context: C) -> Void {
    _visitElement(heading, context)
  }

  override func visit(itemList: ItemListExpr, _ context: C) -> Void {
    _visitElement(itemList, context)
  }

  override func visit(paragraph: ParagraphExpr, _ context: C) -> Void {
    _visitElement(paragraph, context)
  }

  override func visit(parList: ParListExpr, _ context: C) -> Void {
    _visitElement(parList, context)
  }

  override func visit(root: RootExpr, _ context: C) -> Void {
    _visitElement(root, context)
  }

  override func visit(textStyles: TextStylesExpr, _ context: C) -> Void {
    _visitElement(textStyles, context)
  }

  // MARK: - Math

  override func visit(attach: AttachExpr, _ context: C) -> Void {
    willVisitExpression(attach, context)
    defer { didVisitExpression(attach, context) }

    attach.lsub.map { $0.accept(self, context) }
    attach.lsup.map { $0.accept(self, context) }
    attach.nucleus.accept(self, context)
    attach.sub.map { $0.accept(self, context) }
    attach.sup.map { $0.accept(self, context) }
  }

  override func visit(accent: AccentExpr, _ context: C) -> Void {
    willVisitExpression(accent, context)
    defer { didVisitExpression(accent, context) }

    accent.nucleus.accept(self, context)
  }

  override func visit(equation: EquationExpr, _ context: C) -> Void {
    willVisitExpression(equation, context)
    defer { didVisitExpression(equation, context) }
    equation.nucleus.accept(self, context)
  }

  override func visit(fraction: FractionExpr, _ context: C) -> Void {
    willVisitExpression(fraction, context)
    defer { didVisitExpression(fraction, context) }
    fraction.numerator.accept(self, context)
    fraction.denominator.accept(self, context)
  }

  override func visit(leftRight: LeftRightExpr, _ context: C) -> Void {
    willVisitExpression(leftRight, context)
    defer { didVisitExpression(leftRight, context) }
    leftRight.nucleus.accept(self, context)
  }

  override func visit(mathAttributes: MathAttributesExpr, _ context: C) -> Void {
    willVisitExpression(mathAttributes, context)
    defer { didVisitExpression(mathAttributes, context) }
    mathAttributes.nucleus.accept(self, context)
  }

  override func visit(mathExpression: MathExpressionExpr, _ context: C) -> Void {
    willVisitExpression(mathExpression, context)
    do { didVisitExpression(mathExpression, context) }
    // no-op
  }

  override func visit(mathOperator: MathOperatorExpr, _ context: C) -> Void {
    willVisitExpression(mathOperator, context)
    do { didVisitExpression(mathOperator, context) }
    // no-op
  }

  override func visit(namedSymbol: NamedSymbolExpr, _ context: C) -> Void {
    willVisitExpression(namedSymbol, context)
    do { didVisitExpression(namedSymbol, context) }
    // no-op
  }

  override func visit(mathStyles: MathStylesExpr, _ context: C) -> Void {
    willVisitExpression(mathStyles, context)
    defer { didVisitExpression(mathStyles, context) }
    mathStyles.nucleus.accept(self, context)
  }

  override func visit(matrix: MatrixExpr, _ context: C) -> Void {
    willVisitExpression(matrix, context)
    defer { didVisitExpression(matrix, context) }

    for i in 0..<matrix.rowCount {
      for j in 0..<matrix.columnCount {
        matrix.get(i, j).accept(self, context)
      }
    }
  }

  override func visit(multiline: MultilineExpr, _ context: C) -> Void {
    willVisitExpression(multiline, context)
    defer { didVisitExpression(multiline, context) }

    for i in 0..<multiline.rowCount {
      for j in 0..<multiline.columnCount {
        multiline.get(i, j).accept(self, context)
      }
    }
  }

  override func visit(radical: RadicalExpr, _ context: C) -> Void {
    willVisitExpression(radical, context)
    defer { didVisitExpression(radical, context) }
    radical.index.map { $0.accept(self, context) }
    radical.radicand.accept(self, context)
  }

  override func visit(textMode: TextModeExpr, _ context: C) -> Void {
    willVisitExpression(textMode, context)
    defer { didVisitExpression(textMode, context) }
    textMode.nucleus.accept(self, context)
  }

  override func visit(underOver: UnderOverExpr, _ context: C) -> Void {
    willVisitExpression(underOver, context)
    defer { didVisitExpression(underOver, context) }
    underOver.nucleus.accept(self, context)
  }

}

extension ExpressionWalker {
  func traverseExpression(_ expression: Expr, _ context: C) {
    expression.accept(self, context)
  }

  func traverseExpressions(_ expressions: Array<Expr>, _ context: C) {
    for expression in expressions {
      traverseExpression(expression, context)
    }
  }
}
