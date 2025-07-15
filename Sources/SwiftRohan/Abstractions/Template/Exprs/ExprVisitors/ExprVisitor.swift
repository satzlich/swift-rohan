// Copyright 2024-2025 Lie Yan

import Foundation

class ExprVisitor<C, R> {
  typealias Context = C
  typealias Result = R

  func visitExpr(_ expression: Expr, _ context: C) -> R {
    preconditionFailure("overriding required")
  }

  func visit(counter: CounterExpr, _ context: C) -> R {
    visitExpr(counter, context)
  }

  func visit(linebreak: LinebreakExpr, _ context: C) -> R {
    visitExpr(linebreak, context)
  }

  func visit(namedSymbol: NamedSymbolExpr, _ context: C) -> R {
    visitExpr(namedSymbol, context)
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

  func visit(heading: HeadingExpr, _ context: C) -> R {
    visitExpr(heading, context)
  }

  func visit(itemList: ItemListExpr, _ context: C) -> R {
    visitExpr(itemList, context)
  }

  func visit(paragraph: ParagraphExpr, _ context: C) -> R {
    visitExpr(paragraph, context)
  }

  func visit(parList: ParListExpr, _ context: C) -> R {
    visitExpr(parList, context)
  }

  func visit(root: RootExpr, _ context: C) -> R {
    visitExpr(root, context)
  }

  func visit(textStyles: TextStylesExpr, _ context: C) -> R {
    visitExpr(textStyles, context)
  }

  // MARK: - Math

  func visit(accent: AccentExpr, _ context: C) -> R {
    visitExpr(accent, context)
  }

  func visit(attach: AttachExpr, _ context: C) -> R {
    visitExpr(attach, context)
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

  func visit(mathAttributes: MathAttributesExpr, _ context: C) -> R {
    visitExpr(mathAttributes, context)
  }

  func visit(mathExpression: MathExpressionExpr, _ context: C) -> R {
    visitExpr(mathExpression, context)
  }

  func visit(mathOperator: MathOperatorExpr, _ context: C) -> R {
    visitExpr(mathOperator, context)
  }

  func visit(mathStyles: MathStylesExpr, _ context: C) -> R {
    visitExpr(mathStyles, context)
  }

  func visit(matrix: MatrixExpr, _ context: C) -> R {
    visitExpr(matrix, context)
  }

  func visit(multiline: MultilineExpr, _ context: C) -> R {
    visitExpr(multiline, context)
  }

  func visit(radical: RadicalExpr, _ context: C) -> R {
    visitExpr(radical, context)
  }

  func visit(textMode: TextModeExpr, _ context: C) -> R {
    visitExpr(textMode, context)
  }

  func visit(underOver: UnderOverExpr, _ context: C) -> R {
    visitExpr(underOver, context)
  }

}
