// Copyright 2024-2025 Lie Yan

import Foundation

class ExpressionVisitor<C, R> {
  typealias Context = C
  typealias Result = R

  func visitExpr(_ expression: Expr, _ context: C) -> R {
    preconditionFailure("overriding required")
  }

  func visit(text: TextExpr, _ context: C) -> R {
    visitExpr(text, context)
  }

  func visit(unknown: UnknownExpr, _ context: C) -> R {
    visitExpr(unknown, context)
  }

  // MARK: - Template

  func visit(apply: ApplyExpr, _ context: C) -> R {
    visitExpr(apply, context)
  }

  func visit(variable: VariableExpr, _ context: C) -> R {
    visitExpr(variable, context)
  }

  func visit(cVariable: CompiledVariableExpr, _ context: C) -> R {
    visitExpr(cVariable, context)
  }

  // MARK: - Element

  func visit(content: ContentExpr, _ context: C) -> R {
    visitExpr(content, context)
  }

  func visit(emphasis: EmphasisExpr, _ context: C) -> R {
    visitExpr(emphasis, context)
  }

  func visit(heading: HeadingExpr, _ context: C) -> R {
    visitExpr(heading, context)
  }

  func visit(paragraph: ParagraphExpr, _ context: C) -> R {
    visitExpr(paragraph, context)
  }

  func visit(strong: StrongExpr, _ context: C) -> R {
    visitExpr(strong, context)
  }

  // MARK: - Math

  func visit(accent: AccentExpr, _ context: C) -> R {
    visitExpr(accent, context)
  }

  func visit(attach: AttachExpr, _ context: C) -> R {
    visitExpr(attach, context)
  }

  func visit(cases: CasesExpr, _ context: C) -> R {
    visitExpr(cases, context)
  }

  func visit(equation: EquationExpr, _ context: C) -> R {
    visitExpr(equation, context)
  }

  func visit(fraction: FractionExpr, _ context: C) -> R {
    visitExpr(fraction, context)
  }

  func visit(leftRight: LeftRightExpr, _ context: C) -> R {
    visitExpr(leftRight, context)
  }

  func visit(matrix: MatrixExpr, _ context: C) -> R {
    visitExpr(matrix, context)
  }

}
