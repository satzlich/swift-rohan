// Copyright 2024-2025 Lie Yan

import Foundation
import OrderedCollections

extension NodeUtils {
  static func applyTemplate(
    _ template: CompiledTemplate, _ arguments: [[Node]]
  ) -> (ContentNode, [ArgumentNode])? {
    precondition(template.parameterCount == arguments.count)

    // expand template body
    let contentNode = {
      let nodes = ExpressionToNodeVisitor.convertExpressions(template.body.expressions)
      return ContentNode(nodes)
    }()

    // create argument node from paths
    // index is the argument index
    func createArgumentNode(_ paths: OrderedSet<Nano.TreePath>, _ index: Int) -> ArgumentNode? {
      precondition(!paths.isEmpty)
      var variables: [VariableNode] = []
      variables.reserveCapacity(paths.count)

      for path in paths {
        guard let (_, node) = traceNodes(path, contentNode),
          let variableNode = node as? VariableNode
        else { return nil }
        variables.append(variableNode)
      }
      return ArgumentNode(variables, index)
    }

    // gather argument nodes
    var argumentNodes: [ArgumentNode] = []
    argumentNodes.reserveCapacity(template.parameterCount)
    for (i, paths) in template.variableLocations.enumerated() {
      guard let argumentNode = createArgumentNode(paths, i) else { return nil }
      argumentNodes.append(argumentNode)
    }

    // insert values to argument nodes
    for (argumentNode, value) in zip(argumentNodes, arguments) {
      argumentNode.insertChildren(contentsOf: value, at: 0)
    }

    return (contentNode, argumentNodes)
  }
}

private final class ExpressionToNodeVisitor: ExpressionVisitor<Void, Node> {
  static func convertExpressions(_ expressions: [Expression]) -> [Node] {
    let visitor = ExpressionToNodeVisitor()
    return expressions.map({ visitor.visit(expression: $0, ()) })
  }

  // MARK: - Text

  override func visit(text: Text, _ context: Void) -> TextNode {
    TextNode(text.string)
  }

  // MARK: - Template

  override func visit(apply: Apply, _ context: Void) -> ApplyNode {
    fatalError("The input should be free of apply")
  }

  override func visit(variable: Variable, _ context: Void) -> VariableNode {
    fatalError("The input should be free of (named) variable")
  }

  override func visit(namelessVariable: NamelessVariable, _ context: Void) -> VariableNode {
    VariableNode()
  }

  // MARK: - Element

  private func visitChildren(_ children: [Expression], _ context: Void) -> [Node] {
    children.map({ self.visit(expression: $0, context) })
  }

  override func visit(content: Content, _ context: Void) -> ContentNode {
    let children = visitChildren(content.expressions, context)
    return ContentNode(children)
  }

  override func visit(heading: Heading, _ context: Void) -> HeadingNode {
    fatalError("The input should be free of heading")
  }

  override func visit(emphasis: Emphasis, _ context: Void) -> EmphasisNode {
    let children = visitChildren(emphasis.content.expressions, context)
    return EmphasisNode(children)
  }

  override func visit(paragraph: Paragraph, _ context: Void) -> ParagraphNode {
    fatalError("The input should be free of paragraph")
  }

  // MARK: - Math

  override func visit(equation: Equation, _ context: Void) -> EquationNode {
    fatalError("The input should be free of equation")
  }

  override func visit(fraction: Fraction, _ context: Void) -> FractionNode {
    let numerator = visitChildren(fraction.numerator.expressions, context)
    let denominator = visitChildren(fraction.denominator.expressions, context)
    return FractionNode(numerator, denominator, isBinomial: fraction.isBinomial)
  }

  override func visit(matrix: Matrix, _ context: Void) -> Node {
    preconditionFailure("TODO: implement")
  }

  override func visit(scripts: Scripts, _ context: Void) -> Node {
    preconditionFailure("TODO: implement")
  }
}
