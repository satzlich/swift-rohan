// Copyright 2024-2025 Lie Yan

import Foundation

class ExpressionWalker<C>: ExpressionVisitor<C, Void> {
  func willVisitExpression(_ expression: Expr, _ context: C) -> Void {}
  func didVisitExpression(_ expression: Expr, _ context: C) -> Void {}

  final override func visitExpr(_ expression: Expr, _ context: C) -> Void {
    assertionFailure("visitExpr should not be called directly")
  }

  override final func visit(text: TextExpr, _ context: C) -> Void {
    willVisitExpression(text, context)
    do { didVisitExpression(text, context) }
  }

  override func visit(unknown: UnknownExpr, _ context: C) -> Void {
    willVisitExpression(unknown, context)
    do { didVisitExpression(unknown, context) }
  }

  // MARK: - Template

  override final func visit(apply: ApplyExpr, _ context: C) -> Void {
    willVisitExpression(apply, context)
    defer { didVisitExpression(apply, context) }
    apply.arguments.forEach { $0.accept(self, context) }
  }

  override final func visit(variable: VariableExpr, _ context: C) -> Void {
    willVisitExpression(variable, context)
    do { didVisitExpression(variable, context) }
  }

  override final func visit(cVariable: CompiledVariableExpr, _ context: C) -> Void {
    willVisitExpression(cVariable, context)
    do { didVisitExpression(cVariable, context) }
  }

  // MARK: - Element

  private func _visitElement(_ element: ElementExpr, _ context: C) {
    willVisitExpression(element, context)
    defer { didVisitExpression(element, context) }
    element.children.forEach { $0.accept(self, context) }
  }

  override final func visit(content: ContentExpr, _ context: C) -> Void {
    _visitElement(content, context)
  }

  override final func visit(emphasis: EmphasisExpr, _ context: C) -> Void {
    _visitElement(emphasis, context)
  }

  override final func visit(heading: HeadingExpr, _ context: C) -> Void {
    _visitElement(heading, context)
  }

  override final func visit(paragraph: ParagraphExpr, _ context: C) -> Void {
    _visitElement(paragraph, context)
  }

  override func visit(strong: StrongExpr, _ context: C) -> Void {
    _visitElement(strong, context)
  }

  // MARK: - Math

  override final func visit(equation: EquationExpr, _ context: C) -> Void {
    willVisitExpression(equation, context)
    defer { didVisitExpression(equation, context) }
    equation.nucleus.accept(self, context)
  }

  override final func visit(fraction: FractionExpr, _ context: C) -> Void {
    willVisitExpression(fraction, context)
    defer { didVisitExpression(fraction, context) }
    fraction.numerator.accept(self, context)
    fraction.denominator.accept(self, context)
  }

  override final func visit(matrix: MatrixExpr, _ context: C) -> Void {
    willVisitExpression(matrix, context)
    defer { didVisitExpression(matrix, context) }
    matrix.rows.forEach { row in
      row.elements.forEach { $0.accept(self, context) }
    }
  }

  override final func visit(scripts: ScriptsExpr, _ context: C) -> Void {
    willVisitExpression(scripts, context)
    defer { didVisitExpression(scripts, context) }

    scripts.lsub.map { $0.accept(self, context) }
    scripts.lsup.map { $0.accept(self, context) }
    scripts.nucleus.accept(self, context)
    scripts.sub.map { $0.accept(self, context) }
    scripts.sup.map { $0.accept(self, context) }
  }
}

extension ExpressionWalker {
  func traverseExpression(_ expression: Expr, _ context: C) {
    expression.accept(self, context)
  }

  func traverseExpressions(_ expressions: [Expr], _ context: C) {
    expressions.forEach { $0.accept(self, context) }
  }
}
