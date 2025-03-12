// Copyright 2024-2025 Lie Yan

import Foundation

class ExpressionVisitor<C, R> {
  typealias Context = C
  typealias Result = R

  func visitExpression(_ expression: Expr, _ context: C) -> R {
    fatalError("visitExpression not implemented")
  }

  func visit(text: TextExpr, _ context: C) -> R {
    visitExpression(text, context)
  }

  func visit(unknown: UnknownExpr, _ context: C) -> R {
    visitExpression(unknown, context)
  }

  // MARK: - Template

  func visit(apply: ApplyExpr, _ context: C) -> R {
    visitExpression(apply, context)
  }

  func visit(variable: VariableExpr, _ context: C) -> R {
    visitExpression(variable, context)
  }

  func visit(cVariable: CompiledVariableExpr, _ context: C) -> R {
    visitExpression(cVariable, context)
  }

  // MARK: - Element

  func visit(content: ContentExpr, _ context: C) -> R {
    visitExpression(content, context)
  }

  func visit(emphasis: EmphasisExpr, _ context: C) -> R {
    visitExpression(emphasis, context)
  }

  func visit(heading: HeadingExpr, _ context: C) -> R {
    visitExpression(heading, context)
  }

  func visit(paragraph: ParagraphExpr, _ context: C) -> R {
    visitExpression(paragraph, context)
  }

  // MARK: - Math

  func visit(equation: EquationExpr, _ context: C) -> R {
    visitExpression(equation, context)
  }

  func visit(fraction: FractionExpr, _ context: C) -> R {
    visitExpression(fraction, context)
  }

  func visit(matrix: MatrixExpr, _ context: C) -> R {
    visitExpression(matrix, context)
  }

  func visit(scripts: ScriptsExpr, _ context: C) -> R {
    visitExpression(scripts, context)
  }
}
