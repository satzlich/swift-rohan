// Copyright 2024-2025 Lie Yan

import Foundation

class SimpleExpressionVisitor<C>: ExpressionVisitor<C, Void> {
  override func visit(text: TextExpr, _ context: C) -> Void {
    // do nothing
  }

  override func visit(unknown: UnknownExpr, _ context: C) -> Void {
    // do nothing
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

  private func _visitElement(_ element: ElementExpr, _ context: C) {
    element.children.forEach { $0.accept(self, context) }
  }

  override func visit(content: ContentExpr, _ context: C) -> Void {
    _visitElement(content, context)
  }

  override func visit(emphasis: EmphasisExpr, _ context: C) -> Void {
    _visitElement(emphasis, context)
  }

  override func visit(heading: HeadingExpr, _ context: C) -> Void {
    _visitElement(heading, context)
  }

  override func visit(paragraph: ParagraphExpr, _ context: C) -> Void {
    _visitElement(paragraph, context)
  }

  override func visit(strong: StrongExpr, _ context: C) -> Void {
    _visitElement(strong, context)
  }

  // MARK: - Math

  private func _visitMath<T: MathExpr>(_ math: T, _ context: C) {
    math.enumerateCompoennts().map(\.content).forEach { $0.accept(self, context) }
  }

  override func visit(attach: AttachExpr, _ context: C) -> Void {
    _visitMath(attach, context)
  }

  override func visit(accent: AccentExpr, _ context: C) -> Void {
    _visitMath(accent, context)
  }

  override func visit(cases: CasesExpr, _ context: C) -> Void {
    for i in 0..<cases.rowCount {
      cases.get(i).accept(self, context)
    }
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

  override func visit(mathOperator: MathOperatorExpr, _ context: C) -> Void {
    _visitElement(mathOperator.content, context)
  }

  override func visit(mathVariant: MathVariantExpr, _ context: C) -> Void {
    _visitElement(mathVariant, context)
  }

  override func visit(matrix: MatrixExpr, _ context: C) -> Void {
    for i in 0..<matrix.rowCount {
      for j in 0..<matrix.columnCount {
        matrix.get(i, j).accept(self, context)
      }
    }
  }

  override func visit(overline: OverlineExpr, _ context: C) -> Void {
    _visitMath(overline, context)
  }

  override func visit(overspreader: OverspreaderExpr, _ context: C) -> Void {
    _visitMath(overspreader, context)
  }

  override func visit(radical: RadicalExpr, _ context: C) -> Void {
    _visitMath(radical, context)
  }

  override func visit(textMode: TextModeExpr, _ context: C) -> Void {
    _visitMath(textMode, context)
  }

  override func visit(underline: UnderlineExpr, _ context: C) -> Void {
    _visitMath(underline, context)
  }

  override func visit(underspreader: UnderspreaderExpr, _ context: C) -> Void {
    _visitMath(underspreader, context)
  }
}
