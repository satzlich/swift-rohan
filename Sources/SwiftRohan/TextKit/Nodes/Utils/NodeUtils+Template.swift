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
      let nodes = convertExprs(template.body)
      return ContentNode(nodes)
    }()

    // create argument node from paths
    func createArgumentNode(_ paths: VariablePaths, _ argumentIndex: Int) -> ArgumentNode?
    {
      precondition(!paths.isEmpty)
      var variables: [VariableNode] = []
      variables.reserveCapacity(paths.count)

      for path in paths {
        guard let node = TreeUtils.getNode(at: path, contentNode),
          let variableNode = node as? VariableNode
        else { return nil }
        variables.append(variableNode)
      }
      return ArgumentNode(variables, argumentIndex)
    }

    // gather argument nodes
    var argumentNodes: [ArgumentNode] = []
    argumentNodes.reserveCapacity(template.parameterCount)
    for (i, paths) in template.lookup.enumerated() {
      guard let argumentNode = createArgumentNode(paths, i) else { return nil }
      argumentNodes.append(argumentNode)
    }

    // insert values to argument nodes
    for (argumentNode, value) in zip(argumentNodes, arguments) {
      // inStorage is false because node is unattched
      argumentNode.insertChildren(contentsOf: value, at: 0, inStorage: false)
    }

    return (contentNode, argumentNodes)
  }

  /// Convert expressions to nodes.
  static func convertExprs(_ expressions: [Expr]) -> [Node] {
    let visitor = ExprToNodeVisitor()
    return expressions.map({ $0.accept(visitor, ()) })
  }
}

private final class ExprToNodeVisitor: ExpressionVisitor<Void, Node> {
  // MARK: - Text

  override func visit(text: TextExpr, _ context: Void) -> TextNode {
    TextNode(text.string)
  }

  override func visit(unknown: UnknownExpr, _ context: Void) -> Node {
    UnknownNode(unknown.data)
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

  private func _convertChildren<T: ElementExpr>(of element: T, _ context: Void) -> [Node]
  {
    element.children.map({ $0.accept(self, context) })
  }

  override func visit(content: ContentExpr, _ context: Void) -> ContentNode {
    let children = _convertChildren(of: content, context)
    return ContentNode(children)
  }

  override func visit(heading: HeadingExpr, _ context: Void) -> HeadingNode {
    let children = _convertChildren(of: heading, context)
    return HeadingNode(level: heading.level, children)
  }

  override func visit(emphasis: EmphasisExpr, _ context: Void) -> EmphasisNode {
    let children = _convertChildren(of: emphasis, context)
    return EmphasisNode(children)
  }

  override func visit(paragraph: ParagraphExpr, _ context: Void) -> ParagraphNode {
    let children = _convertChildren(of: paragraph, context)
    return ParagraphNode(children)
  }

  override func visit(strong: StrongExpr, _ context: Void) -> Node {
    let children = _convertChildren(of: strong, context)
    return StrongNode(children)
  }

  // MARK: - Math

  override func visit(accent: AccentExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: accent.nucleus, context)
    return AccentNode(accent: accent.accent, nucleus: nucleus)
  }

  override func visit(aligned: AlignedExpr, _ context: Void) -> Node {
    let rows = aligned.rows.map { row in
      let elements = row.map { _convertChildren(of: $0, context) }
      return AlignedNode.Row(elements)
    }
    return AlignedNode(rows)
  }

  override func visit(attach: AttachExpr, _ context: Void) -> Node {
    let lsub = attach.lsub.map { _convertChildren(of: $0, context) }
    let lsup = attach.lsup.map { _convertChildren(of: $0, context) }
    let nuc = _convertChildren(of: attach.nucleus, context)
    let sub = attach.sub.map { _convertChildren(of: $0, context) }
    let sup = attach.sup.map { _convertChildren(of: $0, context) }

    return AttachNode(nuc: nuc, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
  }

  override func visit(cases: CasesExpr, _ context: Void) -> Node {
    let rows = cases.rows.map { row in
      let elements = row.map { _convertChildren(of: $0, context) }
      return CasesNode.Row(elements)
    }
    return CasesNode(rows)
  }

  override func visit(equation: EquationExpr, _ context: Void) -> EquationNode {
    let nucleus = _convertChildren(of: equation.nucleus, context)
    return EquationNode(isBlock: equation.isBlock, nuc: nucleus)
  }

  override func visit(fraction: FractionExpr, _ context: Void) -> FractionNode {
    let numerator = _convertChildren(of: fraction.numerator, context)
    let denominator = _convertChildren(of: fraction.denominator, context)
    return FractionNode(num: numerator, denom: denominator, subtype: fraction.subtype)
  }

  override func visit(leftRight: LeftRightExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: leftRight.nucleus, context)
    return LeftRightNode(leftRight.delimiters, nucleus)
  }

  override func visit(mathOperator: MathOperatorExpr, _ context: Void) -> Node {
    let content = _convertChildren(of: mathOperator.content, context)
    return MathOperatorNode(content, mathOperator.limits)
  }

  override func visit(mathVariant: MathVariantExpr, _ context: Void) -> Node {
    let children = _convertChildren(of: mathVariant, context)
    return MathVariantNode(
      mathVariant.mathVariant, bold: mathVariant.bold, italic: mathVariant.italic,
      children)
  }

  override func visit(matrix: MatrixExpr, _ context: Void) -> Node {
    let rows = matrix.rows.map { row in
      let elements = row.map({ _convertChildren(of: $0, context) })
      return _GridNode.Row(elements)
    }
    return MatrixNode(rows, matrix.delimiters)
  }

  override func visit(overline: OverlineExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: overline.nucleus, context)
    return OverlineNode(nucleus)
  }

  override func visit(overspreader: OverspreaderExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: overspreader.nucleus, context)
    return OverspreaderNode(overspreader.spreader, nucleus)
  }

  override func visit(radical: RadicalExpr, _ context: Void) -> Node {
    let radicand = _convertChildren(of: radical.radicand, context)
    let index = radical.index.map { _convertChildren(of: $0, context) }
    return RadicalNode(radicand, index)
  }

  override func visit(textMode: TextModeExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: textMode.nucleus, context)
    return TextModeNode(nucleus)
  }

  override func visit(underline: UnderlineExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: underline.nucleus, context)
    return UnderlineNode(nucleus)
  }

  override func visit(underspreader: UnderspreaderExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: underspreader.nucleus, context)
    return UnderspreaderNode(underspreader.spreader, nucleus)
  }
}
