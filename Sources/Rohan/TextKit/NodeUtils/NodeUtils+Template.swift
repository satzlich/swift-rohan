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
      let nodes = ExpressionToNodeVisitor.convertExpressions(template.body)
      return ContentNode(nodes)
    }()

    // create argument node from paths
    // index is the argument index
    func createArgumentNode(_ paths: OrderedSet<TreePath>, _ index: Int) -> ArgumentNode? {
      precondition(!paths.isEmpty)
      var variables: [VariableNode] = []
      variables.reserveCapacity(paths.count)

      for path in paths {
        guard let trace = NodeUtils.traceNodes(path[...], contentNode),
          let node = trace.last?.getChild(),
          let variableNode = node as? VariableNode
        else { return nil }
        variables.append(variableNode)
      }
      return ArgumentNode(variables, index)
    }

    // gather argument nodes
    var argumentNodes: [ArgumentNode] = []
    argumentNodes.reserveCapacity(template.parameterCount)
    for (i, paths) in template.variablePaths.enumerated() {
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
  static func convertExpressions(_ expressions: [RhExpr]) -> [Node] {
    let visitor = ExpressionToNodeVisitor()
    return expressions.map({ $0.accept(visitor, ()) })
  }

  // MARK: - Text

  override func visit(text: TextExpr, _ context: Void) -> TextNode {
    TextNode(text.string)
  }

  // MARK: - Template

  override func visit(apply: ApplyExpr, _ context: Void) -> ApplyNode {
    fatalError("The input should be free of apply")
  }

  override func visit(variable: VariableExpr, _ context: Void) -> VariableNode {
    fatalError("The input should be free of (named) variable")
  }

  override func visit(unnamedVariable: UnnamedVariableExpr, _ context: Void) -> Node {
    VariableNode()
  }

  // MARK: - Element

  private func _visitChildren(_ children: [RhExpr], _ context: Void) -> [Node] {
    children.map({ $0.accept(self, context) })
  }

  override func visit(content: ContentExpr, _ context: Void) -> ContentNode {
    let children = _visitChildren(content.expressions, context)
    return ContentNode(children)
  }

  override func visit(heading: HeadingExpr, _ context: Void) -> HeadingNode {
    fatalError("The input should be free of heading")
  }

  override func visit(emphasis: EmphasisExpr, _ context: Void) -> EmphasisNode {
    let children = _visitChildren(emphasis.expressions, context)
    return EmphasisNode(children)
  }

  override func visit(paragraph: ParagraphExpr, _ context: Void) -> ParagraphNode {
    fatalError("The input should be free of paragraph")
  }

  // MARK: - Math

  override func visit(equation: EquationExpr, _ context: Void) -> EquationNode {
    fatalError("The input should be free of equation")
  }

  override func visit(fraction: FractionExpr, _ context: Void) -> FractionNode {
    let numerator = _visitChildren(fraction.numerator.expressions, context)
    let denominator = _visitChildren(fraction.denominator.expressions, context)
    return FractionNode(numerator, denominator, isBinomial: fraction.isBinomial)
  }

  override func visit(matrix: MatrixExpr, _ context: Void) -> Node {
    preconditionFailure("TODO: implement")
  }

  override func visit(scripts: ScriptsExpr, _ context: Void) -> Node {
    preconditionFailure("TODO: implement")
  }
}
