import Foundation
import OrderedCollections

extension NodeUtils {
  static func applyTemplate(
    _ template: CompiledTemplate, _ arguments: Array<ElementStore>
  ) -> (ExpansionNode, Array<ArgumentNode>)? {
    precondition(template.parameterCount == arguments.count)

    // expand template body
    let contentNode = ExpansionNode(convertExprs(template.body), template.layoutType)

    // create argument node from paths
    func createArgumentNode(_ paths: VariablePaths, _ argumentIndex: Int) -> ArgumentNode?
    {
      precondition(!paths.isEmpty)
      var variables: Array<VariableNode> = []
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
    var argumentNodes: Array<ArgumentNode> = []
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
  static func convertExprs<S: RangeReplaceableCollection<Node>>(
    _ expressions: Array<Expr>
  ) -> S {
    let visitor = ExprToNodeVisitor()
    return S(expressions.lazy.map { $0.accept(visitor, ()) })
  }

  static func convertExpr(_ expression: Expr) -> Node {
    let visitor = ExprToNodeVisitor()
    return expression.accept(visitor, ())
  }
}

private final class ExprToNodeVisitor: ExprVisitor<Void, Node> {
  // MARK: - Misc

  override func visit(counter: CounterExpr, _ context: Void) -> Node {
    CounterNode(counter.counterName)
  }

  override func visit(linebreak: LinebreakExpr, _ context: Void) -> Node {
    LinebreakNode()
  }

  override func visit(text: TextExpr, _ context: Void) -> TextNode {
    TextNode(text.string)
  }

  override func visit(unknown: UnknownExpr, _ context: Void) -> Node {
    UnknownNode(unknown.data)
  }

  // MARK: - Template

  override func visit(apply: ApplyExpr, _ context: Void) -> Node {
    guard let template = MathTemplate.lookup(apply.templateName)
    else { return UnknownNode(.null) }
    let arguments: Array<ElementStore> = apply.arguments
      .map { _convertChildren(of: $0, context) }

    guard let applyNode = ApplyNode(template, arguments)
    else { return UnknownNode(.null) }
    return applyNode
  }

  override func visit(variable: VariableExpr, _ context: Void) -> VariableNode {
    fatalError("The input should be free of (named) variable")
  }

  override func visit(cVariable: CompiledVariableExpr, _ context: Void) -> VariableNode {
    VariableNode(
      cVariable.argumentIndex,
      cVariable.textStyles,
      cVariable.layoutType,
      nestedLevelDelta: cVariable.nestedLevelDetla)
  }

  // MARK: - Element

  private func _convertChildren<T: ElementExpr>(
    of element: T, _ context: Void
  ) -> ElementStore {
    ElementStore(element.children.lazy.map { $0.accept(self, context) })
  }

  override func visit(content: ContentExpr, _ context: Void) -> ContentNode {
    let children = _convertChildren(of: content, context)
    return ContentNode(children)
  }

  override func visit(heading: HeadingExpr, _ context: Void) -> HeadingNode {
    let children = _convertChildren(of: heading, context)
    return HeadingNode(heading.subtype, children)
  }

  override func visit(itemList: ItemListExpr, _ context: Void) -> ItemListNode {
    let children = _convertChildren(of: itemList, context)
    return ItemListNode(itemList.subtype, children)
  }

  override func visit(paragraph: ParagraphExpr, _ context: Void) -> ParagraphNode {
    let children = _convertChildren(of: paragraph, context)
    return ParagraphNode(children)
  }

  override func visit(parList: ParListExpr, _ context: Void) -> Node {
    let children = _convertChildren(of: parList, context)
    return ParListNode(children)
  }

  override func visit(root: RootExpr, _ context: Void) -> RootNode {
    let children = _convertChildren(of: root, context)
    return RootNode(children)
  }

  override func visit(textStyles: TextStylesExpr, _ context: Void) -> TextStylesNode {
    let children = _convertChildren(of: textStyles, context)
    return TextStylesNode(textStyles.subtype, children)
  }

  // MARK: - Math

  override func visit(accent: AccentExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: accent.nucleus, context)
    return AccentNode(accent.accent, nucleus: nucleus)
  }

  override func visit(attach: AttachExpr, _ context: Void) -> Node {
    let lsub = attach.lsub.map { _convertChildren(of: $0, context) }
    let lsup = attach.lsup.map { _convertChildren(of: $0, context) }
    let nuc = _convertChildren(of: attach.nucleus, context)
    let sub = attach.sub.map { _convertChildren(of: $0, context) }
    let sup = attach.sup.map { _convertChildren(of: $0, context) }

    return AttachNode(nuc: nuc, lsub: lsub, lsup: lsup, sub: sub, sup: sup)
  }

  override func visit(equation: EquationExpr, _ context: Void) -> EquationNode {
    let nucleus = _convertChildren(of: equation.nucleus, context)
    return EquationNode(equation.subtype, nucleus)
  }

  override func visit(fraction: FractionExpr, _ context: Void) -> FractionNode {
    let numerator = _convertChildren(of: fraction.numerator, context)
    let denominator = _convertChildren(of: fraction.denominator, context)
    return FractionNode(num: numerator, denom: denominator, genfrac: fraction.genfrac)
  }

  override func visit(leftRight: LeftRightExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: leftRight.nucleus, context)
    return LeftRightNode(leftRight.delimiters, nucleus)
  }

  override func visit(mathAttributes: MathAttributesExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: mathAttributes.nucleus, context)
    return MathAttributesNode(mathAttributes.attributes, nucleus)
  }

  override func visit(mathExpression: MathExpressionExpr, _ context: Void) -> Node {
    MathExpressionNode(mathExpression.mathExpression)
  }

  override func visit(mathOperator: MathOperatorExpr, _ context: Void) -> Node {
    return MathOperatorNode(mathOperator.mathOp)
  }

  override func visit(namedSymbol: NamedSymbolExpr, _ context: Void) -> Node {
    NamedSymbolNode(namedSymbol.namedSymbol)
  }

  override func visit(mathStyles: MathStylesExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: mathStyles.nucleus, context)
    return MathStylesNode(mathStyles.styles, nucleus)
  }

  override func visit(matrix: MatrixExpr, _ context: Void) -> Node {
    typealias Element = MatrixNode.Cell
    let rows = matrix.rows.map { row in
      let elements = row.map { _convertChildren(of: $0, context) }
        .map { Element.init($0) }
      return ArrayNode.Row(elements)
    }
    return MatrixNode(matrix.subtype, rows)
  }

  override func visit(multiline: MultilineExpr, _ context: Void) -> Node {
    typealias Cell = MultilineNode.Cell
    let rows = multiline.rows.map { row in
      let elements = row.map { _convertChildren(of: $0, context) }
        .map { Cell.init($0) }
      return ArrayNode.Row(elements)
    }
    return MultilineNode(multiline.subtype, rows)
  }

  override func visit(radical: RadicalExpr, _ context: Void) -> Node {
    let radicand = _convertChildren(of: radical.radicand, context)
    let index = radical.index.map { _convertChildren(of: $0, context) }
    return RadicalNode(radicand, index: index)
  }

  override func visit(textMode: TextModeExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: textMode.nucleus, context)
    return TextModeNode(nucleus)
  }

  override func visit(underOver: UnderOverExpr, _ context: Void) -> Node {
    let nucleus = _convertChildren(of: underOver.nucleus, context)
    return UnderOverNode(underOver.spreader, nucleus)
  }
}
