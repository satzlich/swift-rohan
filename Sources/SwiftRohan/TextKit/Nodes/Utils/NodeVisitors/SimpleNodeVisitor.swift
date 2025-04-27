// Copyright 2024-2025 Lie Yan

class SimpleNodeVisitor<C>: NodeVisitor<Void, C> {
  // MARK: - Children

  private final func _visitChildren<T: ElementNode>(of node: T, _ context: C) {
    for i in 0..<node.childCount {
      node.getChild(i).accept(self, context)
    }
  }

  private final func _visitChildren(of node: ArgumentNode, _ context: C) {
    for i in 0..<node.childCount {
      node.getChild(i).accept(self, context)
    }
  }

  private final func _visitArguments(of node: ApplyNode, _ context: C) {
    for i in 0..<node.argumentCount {
      node.getArgument(i).accept(self, context)
    }
  }

  private final func _visitComponents<T: MathNode>(of node: T, _ context: C) {
    node.enumerateComponents()
      .map(\.content)
      .forEach { $0.accept(self, context) }
  }

  // MARK: - General

  override public func visitNode(_ node: Node, _ context: C) {
    // do nothing
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
    _visitArguments(of: apply, context)
  }

  override public func visit(argument: ArgumentNode, _ context: C) -> Void {
    visitNode(argument, context)
    _visitChildren(of: argument, context)
  }

  override public func visit(variable: VariableNode, _ context: C) -> Void {
    visitNode(variable, context)
    _visitChildren(of: variable, context)
  }

  // MARK: - Element

  override public func visit(content: ContentNode, _ context: C) {
    visitNode(content, context)
    _visitChildren(of: content, context)
  }

  override public func visit(emphasis: EmphasisNode, _ context: C) {
    visitNode(emphasis, context)
    _visitChildren(of: emphasis, context)
  }

  override public func visit(heading: HeadingNode, _ context: C) {
    visitNode(heading, context)
    _visitChildren(of: heading, context)
  }

  override public func visit(paragraph: ParagraphNode, _ context: C) {
    visitNode(paragraph, context)
    _visitChildren(of: paragraph, context)
  }

  override public func visit(root: RootNode, _ context: C) {
    visitNode(root, context)
    _visitChildren(of: root, context)
  }

  override func visit(strong: StrongNode, _ context: C) -> Void {
    visitNode(strong, context)
    _visitChildren(of: strong, context)
  }

  // MARK: - Math

  override public func visit(accent: AccentNode, _ context: C) {
    visitNode(accent, context)
    _visitComponents(of: accent, context)
  }

  override public func visit(attach: AttachNode, _ context: C) {
    visitNode(attach, context)
    _visitComponents(of: attach, context)
  }

  override public func visit(cases: CasesNode, _ context: C) -> Void {
    visitNode(cases, context)
    for i in 0..<cases.rowCount {
      cases.getElement(i).accept(self, context)
    }
  }

  override public func visit(equation: EquationNode, _ context: C) {
    visitNode(equation, context)
    _visitComponents(of: equation, context)
  }

  override public func visit(fraction: FractionNode, _ context: C) {
    visitNode(fraction, context)
    _visitComponents(of: fraction, context)
  }

  override func visit(matrix: MatrixNode, _ context: C) -> Void {
    visitNode(matrix, context)

    for i in 0..<matrix.rowCount {
      for j in 0..<matrix.columnCount {
        matrix.getElement(i, j).accept(self, context)
      }
    }
  }

  override func visit(textMode: TextModeNode, _ context: C) {
    visitNode(textMode, context)
    _visitChildren(of: textMode, context)
  }
}
