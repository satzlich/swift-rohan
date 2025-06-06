// Copyright 2024-2025 Lie Yan

import Foundation

class NodeVisitor<R, C> {
  typealias Result = R
  typealias Context = C

  // MARK: - General

  public func visitNode(_ node: Node, _ context: C) -> R {
    preconditionFailure("overriding required")
  }

  // MARK: - Template

  public func visit(apply: ApplyNode, _ context: C) -> R {
    visitNode(apply, context)
  }

  public func visit(argument: ArgumentNode, _ context: C) -> R {
    visitNode(argument, context)
  }

  internal func visit<T: GenNode, S: Collection<T>>(
    argument: ArgumentNode, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  public func visit(variable: VariableNode, _ context: C) -> R {
    visitNode(variable, context)
  }

  internal func visit<T: GenNode, S: Collection<T>>(
    variable: VariableNode, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  // MARK: - Misc

  public func visit(linebreak: LinebreakNode, _ context: C) -> R {
    visitNode(linebreak, context)
  }

  public func visit(namedSymbol: NamedSymbolNode, _ context: C) -> R {
    visitNode(namedSymbol, context)
  }

  public func visit(text: TextNode, _ context: C) -> R {
    visitNode(text, context)
  }

  public func visit(unknown: UnknownNode, _ context: C) -> R {
    visitNode(unknown, context)
  }

  // MARK: - Element

  public func visit(content: ContentNode, _ context: C) -> R {
    visitNode(content, context)
  }

  internal func visit<T: GenNode, S: Collection<T>>(
    content: ContentNode, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  public func visit(emphasis: EmphasisNode, _ context: C) -> R {
    visitNode(emphasis, context)
  }

  internal func visit<T: GenNode, S: Collection<T>>(
    emphasis: EmphasisNode, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  public func visit(heading: HeadingNode, _ context: C) -> R {
    visitNode(heading, context)
  }

  internal func visit<T: GenNode, S: Collection<T>>(
    heading: HeadingNode, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  public func visit(paragraph: ParagraphNode, _ context: C) -> R {
    visitNode(paragraph, context)
  }

  internal func visit<T: GenNode, S: Collection<T>>(
    paragraph: ParagraphNode, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  public func visit(root: RootNode, _ context: C) -> R {
    visitNode(root, context)
  }

  internal func visit<T: GenNode, S: Collection<T>>(
    root: RootNode, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  public func visit(strong: StrongNode, _ context: C) -> R {
    visitNode(strong, context)
  }

  internal func visit<T: GenNode, S: Collection<T>>(
    strong: StrongNode, _ context: C, withChildren children: S
  ) -> R {
    preconditionFailure("overriding required")
  }

  // MARK: - Partial

  public func visit(slicedElement: SlicedElement, _ context: C) -> R {
    preconditionFailure("overriding required")
  }

  // MARK: - Math

  public func visit(accent: AccentNode, _ context: C) -> R {
    visitNode(accent, context)
  }

  public func visit(attach: AttachNode, _ context: C) -> R {
    visitNode(attach, context)
  }

  public func visit(equation: EquationNode, _ context: C) -> R {
    visitNode(equation, context)
  }

  public func visit(fraction: FractionNode, _ context: C) -> R {
    visitNode(fraction, context)
  }

  public func visit(leftRight: LeftRightNode, _ context: C) -> R {
    visitNode(leftRight, context)
  }

  public func visit(mathAttributes: MathAttributesNode, _ context: C) -> R {
    visitNode(mathAttributes, context)
  }

  public func visit(mathExpression: MathExpressionNode, _ context: C) -> R {
    visitNode(mathExpression, context)
  }

  public func visit(mathOperator: MathOperatorNode, _ context: C) -> R {
    visitNode(mathOperator, context)
  }

  public func visit(mathStyles: MathStylesNode, _ context: C) -> R {
    visitNode(mathStyles, context)
  }

  public func visit(matrix: MatrixNode, _ context: C) -> R {
    visitNode(matrix, context)
  }

  public func visit(radical: RadicalNode, _ context: C) -> R {
    visitNode(radical, context)
  }

  public func visit(textMode: TextModeNode, _ context: C) -> R {
    visitNode(textMode, context)
  }

  public func visit(underOver: UnderOverNode, _ context: C) -> R {
    visitNode(underOver, context)
  }
}
