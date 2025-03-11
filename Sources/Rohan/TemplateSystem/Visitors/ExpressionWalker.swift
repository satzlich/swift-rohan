// Copyright 2024-2025 Lie Yan

import Foundation

class ExpressionWalker<C>: ExpressionVisitor<C, Void> {
  func willVisitExpression(_ expression: RhExpr, _ context: C) -> Void {}
  func didVisitExpression(_ expression: RhExpr, _ context: C) -> Void {}

  final override func visitExpression(_ expression: RhExpr, _ context: C) -> Void {
    assertionFailure("visitExpression should not be called directly")
  }

  override final func visit(apply: ApplyExpr, _ context: C) -> Void {
    willVisitExpression(apply, context)
    defer { didVisitExpression(apply, context) }
    apply.arguments.forEach { $0.accept(self, context) }
  }

  override final func visit(variable: VariableExpr, _ context: C) -> Void {
    willVisitExpression(variable, context)
    do { didVisitExpression(variable, context) }
  }

  override final func visit(unnamedVariable: UnnamedVariableExpr, _ context: C) -> Void {
    willVisitExpression(unnamedVariable, context)
    do { didVisitExpression(unnamedVariable, context) }
  }

  override final func visit(text: TextExpr, _ context: C) -> Void {
    willVisitExpression(text, context)
    do { didVisitExpression(text, context) }
  }

  private func _visitElement(_ element: ElementExpr, _ context: C) {
    willVisitExpression(element, context)
    defer { didVisitExpression(element, context) }
    element.expressions.forEach { $0.accept(self, context) }
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
    if let subScript = scripts.subScript {
      subScript.accept(self, context)
    }
    if let superScript = scripts.superScript {
      superScript.accept(self, context)
    }
  }
}

extension ExpressionWalker {
  func traverseExpression(_ expression: RhExpr, _ context: C) {
    expression.accept(self, context)
  }

  func traverseExpressions(_ expressions: [RhExpr], _ context: C) {
    expressions.forEach { $0.accept(self, context) }
  }
}
