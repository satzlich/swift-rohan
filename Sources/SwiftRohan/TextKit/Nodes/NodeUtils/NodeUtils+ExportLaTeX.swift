// Copyright 2024-2025 Lie Yan

import LaTeXParser

extension NodeUtils {
  /// Export the given node to LaTeX syntax.
  /// - Parameters:
  ///   - node: The node to export.
  ///   - mode: The layout mode in which the node is situated.
  static func exportLaTeX(_ node: Node, mode: LayoutMode) -> SatzResult<StreamSyntax> {
    let visitor = ExportLaTeXVisitor()
    return node.accept(visitor, mode)
  }

  static func exportLaTeX<T: NodeLike, S: Collection<T>>(
    as node: ElementNode, withChildren children: S, mode: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    let visitor = ExportLaTeXVisitor()
    return node.accept(visitor, mode, withChildren: children)
  }

  static func exportLaTeX<T: NodeLike, S: Collection<T>>(
    as node: ArgumentNode, withChildren children: S, mode: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    let visitor = ExportLaTeXVisitor()
    return node.accept(visitor, mode, withChildren: children)
  }

}

private final class ExportLaTeXVisitor: NodeVisitor<SatzResult<StreamSyntax>, LayoutMode>
{
  typealias R = SatzResult<StreamSyntax>

  private func _composeControlSeq(_ command: String) -> SatzResult<StreamSyntax> {
    guard let commandToken = NameToken(command).map({ ControlSeqToken(name: $0) })
    else { return .failure(SatzError(.ExportLaTeXFailure)) }
    let controlSeq = ControlSeqSyntax(command: commandToken)
    return .success(StreamSyntax([.controlSeq(controlSeq)]))
  }

  /// Compose a control sequence call with given command and components.
  private func _composeControlSeq<C: Collection<Node>>(
    _ command: String, arguments: C, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    guard let command = NameToken(command).map({ ControlSeqToken(name: $0) })
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    let arguments: Array<ComponentSyntax> =
      arguments
      .compactMap { component in component.accept(self, context).success() }
      .map { .group(GroupSyntax($0)) }

    guard arguments.count == arguments.count
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    let controlSeq = ControlSeqSyntax(command: command, arguments: arguments)
    return .success(StreamSyntax([.controlSeq(controlSeq)]))
  }

  /// Compose a control sequence call with given command and the children of the element
  /// as a single argument.
  private func _composeControlSeq<T: NodeLike, C: Collection<T>>(
    _ command: String, children: C, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    guard let command = NameToken(command).map({ ControlSeqToken(name: $0) }),
      let argument = _visitChildren(children, context).success()
    else { return .failure(SatzError(.ExportLaTeXFailure)) }
    let group = GroupSyntax(argument)
    let controlSeq = ControlSeqSyntax(command: command, arguments: [.group(group)])
    return .success(StreamSyntax([.controlSeq(controlSeq)]))
  }

  // MARK: - Misc

  override func visit(
    linebreak: LinebreakNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    let syntax = NewlineSyntax("\n")
    let stream = StreamSyntax([.newline(syntax)])
    return .success(stream)
  }

  override func visit(text: TextNode, _ context: LayoutMode) -> SatzResult<StreamSyntax> {
    let stream = TextSyntax.sanitize(String(text.string), mode: context.forLaTeXParser)
    return .success(stream)
  }

  override func visit(
    unknown: UnknownNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    let stream = TextSyntax.sanitize(unknown.placeholder, mode: context.forLaTeXParser)
    return .success(stream)
  }

  // MARK: - Template

  override func visit(apply: ApplyNode, _ context: LayoutMode) -> SatzResult<StreamSyntax>
  {
    switch apply.template.subtype {
    case .functionCall:
      let command = apply.template.command
      let components = (0..<apply.argumentCount).map { apply.getArgument($0) }
      return _composeControlSeq(command, arguments: components, context)

    case .codeSnippet:
      preconditionFailure("TODO: handle code snippets")
    }
  }

  override func visit(
    argument: ArgumentNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    argument.variableNodes[0].accept(self, context)
  }

  override func visit<T, S>(
    argument: ArgumentNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: NodeLike, T == S.Element, S: Collection {
    argument.variableNodes[0].accept(self, context, withChildren: children)
  }

  override func visit(
    variable: VariableNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    visit(variable: variable, context, withChildren: variable.getChildren_readonly())
  }

  override func visit<T, S>(
    variable: VariableNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: NodeLike, T == S.Element, S: Collection {
    _visitChildren(children, context)
  }

  // MARK: - Element

  private func _visitChildren<T: NodeLike, C: Collection<T>>(
    _ children: C, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    let goodChildren = children.map { $0.accept(self, context) }
      .compactMap { $0.success() }
    guard goodChildren.count == children.count
    else { return .failure(SatzError(.ExportLaTeXFailure)) }
    let stream = goodChildren.flatMap(\.stream)
    return .success(StreamSyntax(stream))
  }

  override func visit(
    content: ContentNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    visit(content: content, context, withChildren: content.getChildren_readonly())
  }

  override func visit<T, S>(
    content: ContentNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: NodeLike, T == S.Element, S: Collection {
    _visitChildren(children, context)
  }

  override func visit(
    emphasis: EmphasisNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    let children = emphasis.getChildren_readonly()
    return visit(emphasis: emphasis, context, withChildren: children)
  }

  override func visit<T, S>(
    emphasis: EmphasisNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: NodeLike, T == S.Element, S: Collection {
    precondition(context == .textMode)
    return _composeControlSeq(emphasis.command, children: children, context)
  }

  override func visit(
    heading: HeadingNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    return visit(heading: heading, context, withChildren: heading.getChildren_readonly())
  }

  override func visit<T, S>(
    heading: HeadingNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: NodeLike, T == S.Element, S: Collection {
    precondition(context == .textMode)
    guard let command = heading.command
    else { return .failure(SatzError(.ExportLaTeXFailure)) }
    return _composeControlSeq(command, children: children, context)
  }

  override func visit(
    paragraph: ParagraphNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    let children = paragraph.getChildren_readonly()
    return visit(paragraph: paragraph, context, withChildren: children)
  }

  override func visit<T, S>(
    paragraph: ParagraphNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: NodeLike, T == S.Element, S: Collection {
    precondition(context == .textMode)
    return _visitChildren(children, context)
  }

  override func visit(root: RootNode, _ context: LayoutMode) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    return visit(root: root, context, withChildren: root.getChildren_readonly())
  }

  override func visit<T, S>(
    root: RootNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: NodeLike, T == S.Element, S: Collection {
    precondition(context == .textMode)

    var stream: Array<StreamletSyntax> = []

    var isParagraph = false
    for (i, child) in children.enumerated() {
      guard let childSyntax = child.accept(self, context).success()
      else { return .failure(SatzError(.ExportLaTeXFailure)) }

      if i > 0 {
        stream.append(.newline(NewlineSyntax("\n")))

        if isParagraphNode(child) && isParagraph {
          stream.append(.newline(NewlineSyntax("\n")))
        }
      }
      stream.append(contentsOf: childSyntax.stream)

      // save whether the child is a paragraph node
      isParagraph = isParagraphNode(child)
    }
    return .success(StreamSyntax(stream))
  }

  override func visit(
    strong: StrongNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    return visit(strong: strong, context, withChildren: strong.getChildren_readonly())
  }

  override func visit<T, S>(
    strong: StrongNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: NodeLike, T == S.Element, S: Collection {
    precondition(context == .textMode)
    return _composeControlSeq(strong.command, children: children, context)
  }

  // MARK: - Partial

  override func visit(
    slicedElement: SlicedElement, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    slicedElement.visitSourceWithChildren(self, context)
  }

  // MARK: - Math

  private func _composeAttach(
    _ nucleus: ContentNode?, sub: ContentNode?, sup: ContentNode?, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)

    guard nucleus != nil || sub != nil || sup != nil
    else { return .success(StreamSyntax([])) }

    let subSyntax: ComponentSyntax?
    if let sub = sub {
      guard let composed = sub.accept(self, context).success()
      else { return .failure(SatzError(.ExportLaTeXFailure)) }
      subSyntax = ComponentSyntax(GroupSyntax(composed))
    }
    else {
      subSyntax = nil
    }

    let supSyntax: ComponentSyntax?
    if let sup = sup {
      guard let composed = sup.accept(self, context).success()
      else { return .failure(SatzError(.ExportLaTeXFailure)) }
      supSyntax = ComponentSyntax(GroupSyntax(composed))
    }
    else {
      supSyntax = nil
    }

    if subSyntax != nil || supSyntax != nil {
      let nucleusSyntax: ComponentSyntax
      if let nucleus = nucleus {
        guard let composed = nucleus.accept(self, context).success()
        else { return .failure(SatzError(.ExportLaTeXFailure)) }
        nucleusSyntax = ComponentSyntax(GroupSyntax(composed))
      }
      else {
        nucleusSyntax = ComponentSyntax(GroupSyntax([]))
      }

      let attach = AttachSyntax(
        nucleus: nucleusSyntax, subscript_: subSyntax, supscript: supSyntax)
      return .success(StreamSyntax([.attach(attach)]))
    }
    else {
      if let nucleus = nucleus {
        return nucleus.accept(self, context)
      }
      else {
        return .success(StreamSyntax([]))
      }
    }
  }

  private func _visitMath(
    command: String, _ node: MathNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    // context can be either text or math mode due to the existence of `textMode` nodes.
    let components = node.enumerateComponents().map(\.content)
    return _composeControlSeq(command, arguments: components, context)
  }

  override func visit(
    accent: AccentNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: accent.accent.command, accent, context)
  }

  override func visit(
    attach: AttachNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)

    var stream: Array<StreamletSyntax> = []
    do {
      guard
        let composed =
          _composeAttach(nil, sub: attach.lsub, sup: attach.lsup, context).success()
      else { return .failure(SatzError(.ExportLaTeXFailure)) }
      stream.append(contentsOf: composed.stream)
    }
    do {
      guard
        let composed =
          _composeAttach(attach.nucleus, sub: attach.sub, sup: attach.sup, context)
          .success()
      else { return .failure(SatzError(.ExportLaTeXFailure)) }
      stream.append(contentsOf: composed.stream)
    }
    return .success(StreamSyntax(stream))
  }

  override func visit(
    equation: EquationNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)

    // switch context
    let context = LayoutMode.mathMode

    guard let nucleus = equation.nucleus.accept(self, context).success()
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    let delimiter: MathSyntax.DelimiterType =
      switch equation.subtype {
      case .inline: .dollar
      case .block: .bracket
      }

    let mathSyntax = MathSyntax(delimiter: delimiter, content: nucleus)
    let stream: Array<StreamletSyntax> = [.math(mathSyntax)]
    return .success(StreamSyntax(stream))
  }

  override func visit(
    fraction: FractionNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: fraction.subtype.command, fraction, context)
  }

  override func visit(
    leftRight: LeftRightNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)

    guard let nucleus = leftRight.nucleus.accept(self, context).success(),
      let leftDelimiter = leftRight.delimiters.open.getComponentSyntax().success(),
      let rightDelimiter = leftRight.delimiters.close.getComponentSyntax().success()
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    let left =
      StreamletSyntax(ControlSeqSyntax(command: .left, arguments: [leftDelimiter]))
    let right =
      StreamletSyntax(ControlSeqSyntax(command: .right, arguments: [rightDelimiter]))
    let stream: Array<StreamletSyntax> = [left] + nucleus.stream + [right]
    return .success(StreamSyntax(stream))
  }

  override func visit(
    mathAttributes: MathAttributesNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: mathAttributes.subtype.command, mathAttributes, context)
  }

  override func visit(
    mathExpression: MathExpressionNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _composeControlSeq(mathExpression.mathExpression.command)
  }

  override func visit(
    mathOperator: MathOperatorNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _composeControlSeq(mathOperator.mathOperator.command)
  }

  override func visit(
    mathVariant: MathVariantNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: mathVariant.styles.command, mathVariant, context)
  }

  override func visit(
    matrix: MatrixNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)

    let envName = matrix.subtype.command
    guard let name = NameToken(envName)
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    var resultRows: Array<ArraySyntax.Row> = []
    resultRows.reserveCapacity(matrix.rowCount)
    for row in (0..<matrix.rowCount).map({ matrix.getRow(at: $0) }) {
      var resultRow: Array<StreamSyntax> = []
      resultRow.reserveCapacity(row.count)
      for cell in row {
        guard let cellSyntax = cell.accept(self, context).success()
        else { return .failure(SatzError(.ExportLaTeXFailure)) }
        resultRow.append(cellSyntax)
      }
      resultRows.append(resultRow)
    }
    let arraySyntax = ArraySyntax(resultRows)
    let arrayEnvSyntax = ArrayEnvSyntax(name: name, wrapped: arraySyntax)
    return .success(StreamSyntax([.arrayEnv(arrayEnvSyntax)]))
  }

  override func visit(
    namedSymbol: NamedSymbolNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    // context can be either text or math mode due to the nature of `namedSymbol`.
    _composeControlSeq(namedSymbol.namedSymbol.command)
  }

  override func visit(
    overline: OverlineNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: overline.command, overline, context)
  }

  override func visit(
    overspreader: OverspreaderNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: overspreader.spreader.command, overspreader, context)
  }

  override func visit(
    radical: RadicalNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)

    guard let command = NameToken(radical.command).map({ ControlSeqToken(name: $0) })
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    var arguments: Array<ComponentSyntax> = []

    if let index = radical.index {
      guard
        let indexSyntax = index.accept(self, context).success()
          .map({ GroupSyntax(.brackets, $0) })
      else { return .failure(SatzError(.ExportLaTeXFailure)) }
      arguments.append(ComponentSyntax(indexSyntax))
    }
    do {
      guard
        let radicandSyntax = radical.radicand.accept(self, context).success()
          .map({ GroupSyntax($0) })
      else { return .failure(SatzError(.ExportLaTeXFailure)) }
      arguments.append(ComponentSyntax(radicandSyntax))
    }
    let controlSeq = ControlSeqSyntax(command: command, arguments: arguments)
    return .success(StreamSyntax([.controlSeq(controlSeq)]))
  }

  override func visit(
    underline: UnderlineNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: underline.command, underline, context)
  }

  override func visit(
    underspreader: UnderspreaderNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: underspreader.spreader.command, underspreader, context)
  }

  override func visit(
    textMode: TextModeNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    // switch context to text mode
    let context = LayoutMode.textMode
    return _visitMath(command: textMode.command, textMode, context)
  }
}
