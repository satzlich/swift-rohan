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

  public func visit(variable: VariableNode, _ context: C) -> R {
    visitNode(variable, context)
  }

  // MARK: - Misc

  public func visit(unknown: UnknownNode, _ context: C) -> R {
    visitNode(unknown, context)
  }

  public func visit(text: TextNode, _ context: C) -> R {
    visitNode(text, context)
  }

  // MARK: - Element

  public func visit(root: RootNode, _ context: C) -> R {
    visitNode(root, context)
  }

  public func visit(paragraph: ParagraphNode, _ context: C) -> R {
    visitNode(paragraph, context)
  }

  public func visit(heading: HeadingNode, _ context: C) -> R {
    visitNode(heading, context)
  }

  public func visit(emphasis: EmphasisNode, _ context: C) -> R {
    visitNode(emphasis, context)
  }

  public func visit(content: ContentNode, _ context: C) -> R {
    visitNode(content, context)
  }

  // MARK: - Math

  public func visit(equation: EquationNode, _ context: C) -> R {
    visitNode(equation, context)
  }

  public func visit(fraction: FractionNode, _ context: C) -> R {
    visitNode(fraction, context)
  }

  public func visit(textMode: TextModeNode, _ context: C) -> R {
    visitNode(textMode, context)
  }
}
