// Copyright 2024-2025 Lie Yan

import LatexParser

extension NodeUtils {
  /// Export the given tree to a LaTeX document.
  static func exportLatexDocument(
    _ rootNode: RootNode, context deparseContext: DeparseContext
  ) -> String? {
    let visitor = ExportLatexVisitor()
    return rootNode.accept(visitor, .textMode)
      .map { DocumentSyntax($0).getLatexContent(deparseContext) }
      .success()
  }

  static func getLatexContent(
    _ rootNode: RootNode, context deparseContext: DeparseContext
  ) -> String? {
    let visitor = ExportLatexVisitor()
    return rootNode.accept(visitor, .textMode)
      .map { $0.getLatexContent(deparseContext) }
      .success()
  }

  static func getLatexContent<E: GenElementNode, N: GenNode, S: Collection<N>>(
    as node: E, withChildren children: S,
    mode: LayoutMode, context deparseContext: DeparseContext
  ) -> String? {
    let visitor = ExportLatexVisitor()
    return node.accept(visitor, mode, withChildren: children)
      .map { $0.getLatexContent(deparseContext) }
      .success()
  }
}

private final class ExportLatexVisitor: NodeVisitor<SatzResult<StreamSyntax>, LayoutMode>
{
  typealias R = SatzResult<StreamSyntax>

  private func _composeControlSeq(_ command: String) -> SatzResult<StreamSyntax> {
    guard let commandToken = NameToken(command).map({ ControlWordToken(name: $0) })
    else { return .failure(SatzError(.ExportLatexFailure)) }
    let controlWord = ControlWordSyntax(command: commandToken)
    return .success(StreamSyntax([.controlWord(controlWord)]))
  }

  /// Compose a control sequence call with given command and components.
  private func _composeControlSeqCall<T: Node>(
    _ command: String, arguments: Array<T>, _ context: LayoutMode,
    affixPosition: AffixPosition = .prefix
  ) -> SatzResult<StreamSyntax> {

    guard (affixPosition != .infix || arguments.count == 2),
      (affixPosition != .postfix || arguments.count == 1),
      let command = NameToken(command).map({ ControlWordToken(name: $0) })
    else {
      return .failure(SatzError(.ExportLatexFailure))
    }

    let argumentSyntaxes: Array<StreamSyntax> =
      arguments.compactMap { component in component.accept(self, context).success() }

    guard argumentSyntaxes.count == arguments.count else {
      return .failure(SatzError(.ExportLatexFailure))
    }

    switch affixPosition {
    case .prefix:
      let groupedArguments: Array<ComponentSyntax> =
        argumentSyntaxes.map { .group(GroupSyntax($0)) }
      let controlWord = ControlWordSyntax(command: command, arguments: groupedArguments)
      return .success(StreamSyntax([.controlWord(controlWord)]))

    case .infix:
      assert(argumentSyntaxes.count == 2)
      // compose "{ left command right }"
      let left = argumentSyntaxes[0]
      let right = argumentSyntaxes[1]
      let command = ControlWordSyntax(command: command)
      let content = left.stream + [.controlWord(command)] + right.stream
      return .success(StreamSyntax([.group(GroupSyntax(StreamSyntax(content)))]))

    case .postfix:
      assert(argumentSyntaxes.count == 1)
      // compose "left command"
      let left = argumentSyntaxes[0]
      let controlWord = ControlWordSyntax(command: command)
      let content = left.stream + [.controlWord(controlWord)]
      return .success(StreamSyntax(content))

    case .undefined:
      return .failure(SatzError(.ExportLatexFailure))
    }

  }

  /// Compose a control sequence call with given command and the children of the element
  /// as a single argument.
  private func _composeControlSeqCall<T: GenNode, C: Collection<T>>(
    _ command: String, children: C, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    guard let command = NameToken(command).map({ ControlWordToken(name: $0) }),
      let argument = _visitChildren(children, context).success()
    else { return .failure(SatzError(.ExportLatexFailure)) }
    let group = GroupSyntax(argument)
    let controlWord = ControlWordSyntax(command: command, arguments: [.group(group)])
    return .success(StreamSyntax([.controlWord(controlWord)]))
  }

  // MARK: - Misc

  override func visit(
    linebreak: LinebreakNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    guard let syntax = EscapedCharSyntax(char: "\\")
    else { return .failure(SatzError(.ExportLatexFailure)) }
    let stream = StreamSyntax([.escapedChar(syntax), .space(SpaceSyntax())])
    return .success(stream)
  }

  override func visit(text: TextNode, _ context: LayoutMode) -> SatzResult<StreamSyntax> {
    let stream = TextSyntax.sanitize(
      String(text.string), Rohan.latexRegistry, mode: context.toLatexParserType)
    return .success(stream)
  }

  override func visit(
    unknown: UnknownNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    let stream = TextSyntax.sanitize(
      unknown.placeholder, Rohan.latexRegistry, mode: context.toLatexParserType)
    return .success(stream)
  }

  // MARK: - Template

  override func visit(apply: ApplyNode, _ context: LayoutMode) -> SatzResult<StreamSyntax>
  {
    switch apply.template.subtype {
    case .functionCall:
      let command = apply.template.command
      let components = (0..<apply.argumentCount).map { apply.getArgument($0) }
      return _composeControlSeqCall(command, arguments: components, context)

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
  ) -> SatzResult<StreamSyntax> where T: GenNode, T == S.Element, S: Collection {
    argument.variableNodes[0].accept(self, context, withChildren: children)
  }

  override func visit(
    variable: VariableNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    visit(variable: variable, context, withChildren: variable.childrenReadonly())
  }

  override func visit<T, S>(
    variable: VariableNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: GenNode, T == S.Element, S: Collection {
    _visitChildren(children, context)
  }

  // MARK: - Element

  private func _visitChildren<T: GenNode, C: Collection<T>>(
    _ children: C, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    let goodChildren = children.map { $0.accept(self, context) }
      .compactMap { $0.success() }
    guard goodChildren.count == children.count
    else { return .failure(SatzError(.ExportLatexFailure)) }
    let stream = goodChildren.flatMap(\.stream)
    return .success(StreamSyntax(stream))
  }

  override func visit(
    content: ContentNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    visit(content: content, context, withChildren: content.childrenReadonly())
  }

  override func visit<T, S>(
    content: ContentNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: GenNode, T == S.Element, S: Collection {
    _visitChildren(children, context)
  }

  override func visit(
    emphasis: EmphasisNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    let children = emphasis.childrenReadonly()
    return visit(emphasis: emphasis, context, withChildren: children)
  }

  override func visit<T, S>(
    emphasis: EmphasisNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: GenNode, T == S.Element, S: Collection {
    precondition(context == .textMode)
    return _composeControlSeqCall(emphasis.command, children: children, context)
  }

  override func visit(
    heading: HeadingNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    return visit(heading: heading, context, withChildren: heading.childrenReadonly())
  }

  override func visit<T, S>(
    heading: HeadingNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: GenNode, T == S.Element, S: Collection {
    precondition(context == .textMode)
    guard let command = heading.command
    else { return .failure(SatzError(.ExportLatexFailure)) }
    return _composeControlSeqCall(command, children: children, context)
  }

  override func visit(
    paragraph: ParagraphNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    let children = paragraph.childrenReadonly()
    return visit(paragraph: paragraph, context, withChildren: children)
  }

  override func visit<T, S>(
    paragraph: ParagraphNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: GenNode, T == S.Element, S: Collection {
    precondition(context == .textMode)
    return _visitChildren(children, context)
  }

  override func visit(root: RootNode, _ context: LayoutMode) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    return visit(root: root, context, withChildren: root.childrenReadonly())
  }

  override func visit<T, S>(
    root: RootNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: GenNode, T == S.Element, S: Collection {
    precondition(context == .textMode)

    var stream: Array<StreamletSyntax> = []

    var isParagraph = false
    for (i, child) in children.enumerated() {
      guard let childSyntax = child.accept(self, context).success()
      else { return .failure(SatzError(.ExportLatexFailure)) }

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
    return visit(strong: strong, context, withChildren: strong.childrenReadonly())
  }

  override func visit<T, S>(
    strong: StrongNode, _ context: LayoutMode, withChildren children: S
  ) -> SatzResult<StreamSyntax> where T: GenNode, T == S.Element, S: Collection {
    precondition(context == .textMode)
    return _composeControlSeqCall(strong.command, children: children, context)
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
      else { return .failure(SatzError(.ExportLatexFailure)) }
      subSyntax = ComponentSyntax(GroupSyntax(composed))
    }
    else {
      subSyntax = nil
    }

    let supSyntax: ComponentSyntax?
    if let sup = sup {
      guard let composed = sup.accept(self, context).success()
      else { return .failure(SatzError(.ExportLatexFailure)) }
      supSyntax = ComponentSyntax(GroupSyntax(composed))
    }
    else {
      supSyntax = nil
    }

    if subSyntax != nil || supSyntax != nil {
      let nucleusSyntax: ComponentSyntax
      if let nucleus = nucleus {
        guard let composed = nucleus.accept(self, context).success()
        else { return .failure(SatzError(.ExportLatexFailure)) }
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
    command: String, _ node: MathNode, _ context: LayoutMode,
    affixPosition: AffixPosition = .prefix
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode || context == .textMode)  // due to TextModeNode

    let components = node.enumerateComponents().map(\.content)

    // infix => 2 arguments
    guard (affixPosition != .infix || components.count == 2) else {
      return .failure(SatzError(.ExportLatexFailure))
    }

    return _composeControlSeqCall(
      command, arguments: components, context, affixPosition: affixPosition)
  }

  private func _visitArray(
    command: String, _ node: ArrayNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)

    let envName = node.subtype.command
    guard let name = NameToken(envName)
    else { return .failure(SatzError(.ExportLatexFailure)) }

    var resultRows: Array<ArraySyntax.Row> = []
    resultRows.reserveCapacity(node.rowCount)
    for row in (0..<node.rowCount).map({ node.getRow(at: $0) }) {
      var resultRow: Array<StreamSyntax> = []
      resultRow.reserveCapacity(row.count)
      for cell in row {
        guard let cellSyntax = cell.accept(self, context).success()
        else { return .failure(SatzError(.ExportLatexFailure)) }
        resultRow.append(cellSyntax)
      }
      resultRows.append(resultRow)
    }
    let arraySyntax = ArraySyntax(resultRows)
    let arrayEnvSyntax = ArrayEnvSyntax(name: name, wrapped: arraySyntax)
    return .success(StreamSyntax([.arrayEnv(arrayEnvSyntax)]))
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
      else { return .failure(SatzError(.ExportLatexFailure)) }
      stream.append(contentsOf: composed.stream)
    }
    do {
      guard
        let composed =
          _composeAttach(attach.nucleus, sub: attach.sub, sup: attach.sup, context)
          .success()
      else { return .failure(SatzError(.ExportLatexFailure)) }
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
    else { return .failure(SatzError(.ExportLatexFailure)) }

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
    let subtype = fraction.genfrac
    return _visitMath(
      command: subtype.command, fraction, context,
      affixPosition: subtype.affixPosition)
  }

  override func visit(
    leftRight: LeftRightNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)

    guard let nucleus = leftRight.nucleus.accept(self, context).success(),
      let leftDelimiter = leftRight.delimiters.open.getComponentSyntax().success(),
      let rightDelimiter = leftRight.delimiters.close.getComponentSyntax().success()
    else { return .failure(SatzError(.ExportLatexFailure)) }

    let left =
      StreamletSyntax(ControlWordSyntax(command: .left, arguments: [leftDelimiter]))
    let right =
      StreamletSyntax(ControlWordSyntax(command: .right, arguments: [rightDelimiter]))
    let stream: Array<StreamletSyntax> = [left] + nucleus.stream + [right]
    return .success(StreamSyntax(stream))
  }

  override func visit(
    mathAttributes: MathAttributesNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    switch mathAttributes.subtype {
    // for limits, put \limits or \nolimits in postfix position.
    case .mathLimits(let limits):
      guard let nucleus = mathAttributes.nucleus.accept(self, context).success(),
        let limitsCommand = NameToken(limits.command).map({ ControlWordToken(name: $0) })
      else { return .failure(SatzError(.ExportLatexFailure)) }
      let limitsSyntax = ControlWordSyntax(command: limitsCommand)

      if let element = mathAttributes.nucleus.childrenReadonly().getOnlyElement(),
        isMathOperator(element)
      {
        let stream = StreamSyntax(nucleus.stream + [.controlWord(limitsSyntax)])
        return .success(stream)
      }
      else {
        // if nucleus is not a math operator, wrap it in a \mathop{...} group
        guard let mahtopCommand = NameToken("mathop").map({ ControlWordToken(name: $0) })
        else { return .failure(SatzError(.ExportLatexFailure)) }
        let mathopSyntax = ControlWordSyntax(
          command: mahtopCommand, arguments: [ComponentSyntax(GroupSyntax(nucleus))])
        let stream = StreamSyntax([
          .controlWord(mathopSyntax), .controlWord(limitsSyntax),
        ])
        return .success(stream)
      }

    case .mathKind, .combo:
      return _visitMath(command: mathAttributes.subtype.command, mathAttributes, context)
    }

    /// Returns true if the node is treated as a math operator **in LaTeX**.
    func isMathOperator(_ node: Node) -> Bool {
      switch node {
      case let node as MathAttributesNode:
        return node.subtype.tag.contains(.mathOperator)
      case let node as MathExpressionNode:
        return node.mathExpression.tag.contains(.mathOperator)
      case let node as MathOperatorNode:
        return node.mathOperator.tag.contains(.mathOperator)
      case let node as NamedSymbolNode:
        return node.namedSymbol.tag.contains(.mathOperator)
      default:
        return false
      }
    }
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
    mathStyles: MathStylesNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    switch mathStyles.styles {
    case let .mathStyle(style):
      guard let nucleus = mathStyles.nucleus.accept(self, context).success(),
        let name = NameToken(style.command)
      else { return .failure(SatzError(.ExportLatexFailure)) }
      let command = ControlWordSyntax(command: ControlWordToken(name: name))
      let stream = StreamSyntax([.controlWord(command)] + nucleus.stream)
      let group = GroupSyntax(stream)
      return .success(StreamSyntax([.group(group)]))

    case .mathTextStyle, .toInlineStyle:
      return _visitMath(command: mathStyles.styles.command, mathStyles, context)
    }
  }

  override func visit(
    matrix: MatrixNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    _visitArray(command: matrix.subtype.command, matrix, context)
  }

  override func visit(
    multiline: MultilineNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .textMode)
    // switch context
    let context = LayoutMode.mathMode
    return _visitArray(command: multiline.subtype.command, multiline, context)
  }

  override func visit(
    namedSymbol: NamedSymbolNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    // context can be either text or math mode due to the nature of `namedSymbol`.
    _composeControlSeq(namedSymbol.namedSymbol.command)
  }

  override func visit(
    radical: RadicalNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)

    guard let command = NameToken(radical.command).map({ ControlWordToken(name: $0) })
    else { return .failure(SatzError(.ExportLatexFailure)) }

    var arguments: Array<ComponentSyntax> = []

    if let index = radical.index {
      guard
        let indexSyntax = index.accept(self, context).success()
          .map({ GroupSyntax(.brackets, $0) })
      else { return .failure(SatzError(.ExportLatexFailure)) }
      arguments.append(ComponentSyntax(indexSyntax))
    }
    do {
      guard
        let radicandSyntax = radical.radicand.accept(self, context).success()
          .map({ GroupSyntax($0) })
      else { return .failure(SatzError(.ExportLatexFailure)) }
      arguments.append(ComponentSyntax(radicandSyntax))
    }
    let controlWord = ControlWordSyntax(command: command, arguments: arguments)
    return .success(StreamSyntax([.controlWord(controlWord)]))
  }

  override func visit(
    underOver: UnderOverNode, _ context: LayoutMode
  ) -> SatzResult<StreamSyntax> {
    precondition(context == .mathMode)
    return _visitMath(command: underOver.spreader.command, underOver, context)
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
