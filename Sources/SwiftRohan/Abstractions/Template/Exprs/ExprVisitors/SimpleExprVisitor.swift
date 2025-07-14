// Copyright 2024-2025 Lie Yan

import Foundation

class SimpleExprVisitor<C>: ExprVisitor<C, Void> {

  override func visit(counter: CounterExpr, _ context: C) -> Void {
    // no-op
  }

  override func visit(linebreak: LinebreakExpr, _ context: C) -> Void {
    // no-op
  }

  override func visit(text: TextExpr, _ context: C) -> Void {
    // no-op
  }

  override func visit(unknown: UnknownExpr, _ context: C) -> Void {
    // no-op
  }

  // MARK: - Template

  override func visit(apply: ApplyExpr, _ context: C) -> Void {
    apply.arguments.forEach { $0.accept(self, context) }
  }

  override func visit(variable: VariableExpr, _ context: C) -> Void {
    // do nothing
  }

  override func visit(cVariable: CompiledVariableExpr, _ context: C) -> Void {
    // do nothing
  }

  // MARK: - Elements

  private func _visitElement<T: ElementExpr>(_ element: T, _ context: C) {
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

  override func visit(root: RootExpr, _ context: C) -> Void {
    _visitElement(root, context)
  }

  override func visit(textStyles: TextStylesExpr, _ context: C) -> Void {
    _visitElement(textStyles, context)
  }

  // MARK: - Math

  private func _visitMath<T: MathExpr>(_ math: T, _ context: C) {
    math.enumerateComponents().map(\.content).forEach { $0.accept(self, context) }
  }

  private func _visitArray<T: ArrayExpr>(_ arrayExpr: T, _ context: C) {
    for i in 0..<arrayExpr.rowCount {
      for j in 0..<arrayExpr.columnCount {
        arrayExpr.get(i, j).accept(self, context)
      }
    }
  }

  override func visit(accent: AccentExpr, _ context: C) -> Void {
    _visitMath(accent, context)
  }

  override func visit(attach: AttachExpr, _ context: C) -> Void {
    _visitMath(attach, context)
  }

  override func visit(equation: EquationExpr, _ context: C) -> Void {
    _visitMath(equation, context)
  }

  override func visit(fraction: FractionExpr, _ context: C) -> Void {
    _visitMath(fraction, context)
  }

  override func visit(leftRight: LeftRightExpr, _ context: C) -> Void {
    _visitMath(leftRight, context)
  }

  override func visit(mathAttributes: MathAttributesExpr, _ context: C) -> Void {
    _visitMath(mathAttributes, context)
  }

  override func visit(mathExpression: MathExpressionExpr, _ context: C) -> Void {
    // no-op
  }

  override func visit(mathOperator: MathOperatorExpr, _ context: C) -> Void {
    // no-op
  }

  override func visit(namedSymbol: NamedSymbolExpr, _ context: C) -> Void {
    // no-op
  }

  override func visit(mathStyles: MathStylesExpr, _ context: C) -> Void {
    _visitMath(mathStyles, context)
  }

  override func visit(matrix: MatrixExpr, _ context: C) -> Void {
    _visitArray(matrix, context)
  }

  override func visit(multiline: MultilineExpr, _ context: C) -> Void {
    _visitArray(multiline, context)
  }

  override func visit(radical: RadicalExpr, _ context: C) -> Void {
    _visitMath(radical, context)
  }

  override func visit(textMode: TextModeExpr, _ context: C) -> Void {
    _visitMath(textMode, context)
  }

  override func visit(underOver: UnderOverExpr, _ context: C) -> Void {
    _visitMath(underOver, context)
  }
}
