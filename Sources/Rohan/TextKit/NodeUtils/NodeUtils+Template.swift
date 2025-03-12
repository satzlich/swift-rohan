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
      let nodes = ExprToNodeVisitor.convertExprs(template.body)
      return ContentNode(nodes)
    }()

    // create argument node from paths
    // index is the argument index
    func createArgumentNode(_ paths: VariablePaths, _ index: Int) -> ArgumentNode? {
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

private final class ExprToNodeVisitor: ExpressionVisitor<Void, Node> {
  static func convertExprs(_ expressions: [Expr]) -> [Node] {
    let visitor = ExprToNodeVisitor()
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

  override func visit(cVariable: CompiledVariableExpr, _ context: Void) -> Node {
    VariableNode(cVariable.argumentIndex)
  }

  // MARK: - Element

  private func _convertChildren<T: ElementExpr>(of element: T, _ context: Void) -> [Node] {
    element.children.map({ $0.accept(self, context) })
  }

  override func visit(content: ContentExpr, _ context: Void) -> ContentNode {
    let children = _convertChildren(of: content, context)
    return ContentNode(children)
  }

  override func visit(heading: HeadingExpr, _ context: Void) -> HeadingNode {
    assertionFailure("We don't support \(type(of: heading)) for the moment")
    let children = _convertChildren(of: heading, context)
    return HeadingNode(level: heading.level, children)
  }

  override func visit(emphasis: EmphasisExpr, _ context: Void) -> EmphasisNode {
    let children = _convertChildren(of: emphasis, context)
    return EmphasisNode(children)
  }

  override func visit(paragraph: ParagraphExpr, _ context: Void) -> ParagraphNode {
    assertionFailure("We don't support \(type(of: paragraph)) for the moment")
    let children = _convertChildren(of: paragraph, context)
    return ParagraphNode(children)
  }

  // MARK: - Math

  override func visit(equation: EquationExpr, _ context: Void) -> EquationNode {
    assertionFailure("We don't support \(type(of: equation)) for the moment")
    let nucleus = _convertChildren(of: equation.nucleus, context)
    return EquationNode(isBlock: equation.isBlock, nucleus)
  }

  override func visit(fraction: FractionExpr, _ context: Void) -> FractionNode {
    let numerator = _convertChildren(of: fraction.numerator, context)
    let denominator = _convertChildren(of: fraction.denominator, context)
    return FractionNode(
      numerator: numerator, denominator: denominator, isBinomial: fraction.isBinomial)
  }

  override func visit(matrix: MatrixExpr, _ context: Void) -> Node {
    preconditionFailure("there is no MatrixNode yet")
  }

  override func visit(scripts: ScriptsExpr, _ context: Void) -> Node {
    preconditionFailure("there is no ScriptsNode yet")
  }
}
