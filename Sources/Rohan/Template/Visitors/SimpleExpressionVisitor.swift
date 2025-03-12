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

  private func _visitChildren(_ expressions: [RhExpr], _ context: C) {
    expressions.forEach { $0.accept(self, context) }
  }

  override func visit(content: ContentExpr, _ context: C) -> Void {
    _visitChildren(content.children, context)
  }

  override func visit(emphasis: EmphasisExpr, _ context: C) -> Void {
    _visitChildren(emphasis.children, context)
  }

  override func visit(heading: HeadingExpr, _ context: C) -> Void {
    _visitChildren(heading.children, context)
  }

  override func visit(paragraph: ParagraphExpr, _ context: C) -> Void {
    _visitChildren(paragraph.children, context)
  }

  // MARK: - Math

  override func visit(equation: EquationExpr, _ context: C) -> Void {
    equation.nucleus.accept(self, context)
  }

  override func visit(fraction: FractionExpr, _ context: C) -> Void {
    fraction.numerator.accept(self, context)
    fraction.denominator.accept(self, context)
  }

  override func visit(matrix: MatrixExpr, _ context: C) -> Void {
    matrix.rows.forEach { row in
      row.elements.forEach { $0.accept(self, context) }
    }
  }

  override func visit(scripts: ScriptsExpr, _ context: C) -> Void {
    if let subScript = scripts.subScript {
      subScript.accept(self, context)
    }
    if let superScript = scripts.superScript {
      superScript.accept(self, context)
    }
  }
}
