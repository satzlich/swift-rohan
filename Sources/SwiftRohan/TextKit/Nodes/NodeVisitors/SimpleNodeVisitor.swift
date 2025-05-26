// Copyright 2024-2025 Lie Yan

class SimpleNodeVisitor<C>: NodeVisitor<Void, C> {

  private final func _visitElementNode<T: ElementNode>(_ node: T, _ context: C) {
    visitNode(node, context)
    for i in 0..<node.childCount {
      node.getChild(i).accept(self, context)
    }
  }

  private final func _visitMathNode<T: MathNode>(_ node: T, _ context: C) {
    visitNode(node, context)
    node.enumerateComponents()
      .map(\.content)
      .forEach { $0.accept(self, context) }
  }

  private final func _visitGridNode<T: ArrayNode>(_ node: T, _ context: C) {
    visitNode(node, context)

    for i in 0..<node.rowCount {
      for j in 0..<node.columnCount {
        node.getElement(i, j).accept(self, context)
      }
    }
  }

  // MARK: - General

  override public func visitNode(_ node: Node, _ context: C) {
    // no-op
  }

  // MARK: - Misc

  override func visit(linebreak: LinebreakNode, _ context: C) -> Void {
    visitNode(linebreak, context)
  }

  override public func visit(text: TextNode, _ context: C) {
    visitNode(text, context)
  }

  override public func visit(unknown: UnknownNode, _ context: C) -> Void {
    visitNode(unknown, context)
  }

  // MARK: - Template

  override public func visit(apply: ApplyNode, _ context: C) -> Void {
    visitNode(apply, context)
    for i in 0..<apply.argumentCount {
      apply.getArgument(i).accept(self, context)
    }
  }

  override public func visit(argument: ArgumentNode, _ context: C) -> Void {
    visitNode(argument, context)
    for i in 0..<argument.childCount {
      argument.getChild(i).accept(self, context)
    }
  }

  override public func visit(variable: VariableNode, _ context: C) -> Void {
    _visitElementNode(variable, context)
  }

  // MARK: - Element

  override public func visit(content: ContentNode, _ context: C) {
    _visitElementNode(content, context)
  }

  override public func visit(emphasis: EmphasisNode, _ context: C) {
    _visitElementNode(emphasis, context)
  }

  override public func visit(heading: HeadingNode, _ context: C) {
    _visitElementNode(heading, context)
  }

  override public func visit(paragraph: ParagraphNode, _ context: C) {
    _visitElementNode(paragraph, context)
  }

  override public func visit(root: RootNode, _ context: C) {
    _visitElementNode(root, context)
  }

  override func visit(strong: StrongNode, _ context: C) -> Void {
    _visitElementNode(strong, context)
  }

  // MARK: - Math

  override public func visit(accent: AccentNode, _ context: C) {
    _visitMathNode(accent, context)
  }

  override public func visit(attach: AttachNode, _ context: C) {
    _visitMathNode(attach, context)
  }

  override public func visit(equation: EquationNode, _ context: C) {
    _visitMathNode(equation, context)
  }

  override public func visit(fraction: FractionNode, _ context: C) {
    _visitMathNode(fraction, context)
  }

  override func visit(leftRight: LeftRightNode, _ context: C) -> Void {
    _visitMathNode(leftRight, context)
  }

  override func visit(mathLimits: MathAttributesNode, _ context: C) -> Void {
    visitNode(mathLimits, context)
  }

  override func visit(mathExpression: MathExpressionNode, _ context: C) -> Void {
    visitNode(mathExpression, context)
  }

  override func visit(mathOperator: MathOperatorNode, _ context: C) -> Void {
    visitNode(mathOperator, context)
  }

  override func visit(namedSymbol: NamedSymbolNode, _ context: C) -> Void {
    visitNode(namedSymbol, context)
  }

  override func visit(mathVariant: MathVariantNode, _ context: C) -> Void {
    _visitMathNode(mathVariant, context)
  }

  override func visit(matrix: MatrixNode, _ context: C) -> Void {
    _visitGridNode(matrix, context)
  }

  override func visit(overline: OverlineNode, _ context: C) -> Void {
    _visitMathNode(overline, context)
  }

  override func visit(overspreader: OverspreaderNode, _ context: C) -> Void {
    _visitMathNode(overspreader, context)
  }

  override func visit(radical: RadicalNode, _ context: C) -> Void {
    _visitMathNode(radical, context)
  }

  override func visit(textMode: TextModeNode, _ context: C) {
    _visitMathNode(textMode, context)
  }

  override func visit(underline: UnderlineNode, _ context: C) -> Void {
    _visitMathNode(underline, context)
  }

  override func visit(underspreader: UnderspreaderNode, _ context: C) -> Void {
    _visitMathNode(underspreader, context)
  }
}
