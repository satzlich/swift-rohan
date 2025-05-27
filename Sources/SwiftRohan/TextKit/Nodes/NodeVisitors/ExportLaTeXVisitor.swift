// Copyright 2024-2025 Lie Yan

import LaTeXParser

final class ExportLaTeXVisitor: NodeVisitor<SatzResult<StreamSyntax>, Void> {
  typealias R = SatzResult<StreamSyntax>

  // MARK: - Misc

  override func visit(
    linebreak: LinebreakNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    let syntax = NewlineSyntax("\n")
    let stream = StreamSyntax([.newline(syntax)])
    return .success(stream)
  }

  override func visit(text: TextNode, _ context: Void) -> SatzResult<StreamSyntax> {
    preconditionFailure("TODO: escape certain characters")
  }

  override func visit(unknown: UnknownNode, _ context: Void) -> SatzResult<StreamSyntax> {
    preconditionFailure("TODO: handle unknown nodes")
  }

  // MARK: - Template

  override func visit(apply: ApplyNode, _ context: Void) -> SatzResult<StreamSyntax> {
    switch apply.template.subtype {
    case .functionCall:
      let command = apply.template.command
      let components = (0..<apply.argumentCount).map { apply.getArgument($0) }
      return _composeControlSeq(command, components, context)

    case .codeSnippet:
      preconditionFailure()
    }
  }

  override func visit(argument: ArgumentNode, _ context: Void) -> SatzResult<StreamSyntax>
  {
    argument.variableNodes[0].accept(self, context)
  }

  override func visit(variable: VariableNode, _ context: Void) -> SatzResult<StreamSyntax>
  {
    _visitChildren(variable, context)
  }

  // MARK: - Element

  private func _visitChildren<T: ElementNode>(
    _ node: T, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    preconditionFailure()
  }

  override func visit(content: ContentNode, _ context: Void) -> SatzResult<StreamSyntax> {
    _visitChildren(content, context)
  }

  override func visit(emphasis: EmphasisNode, _ context: Void) -> SatzResult<StreamSyntax>
  {
    _composeControlSeq("emph", emphasis.getChildren_readonly(), context)
  }

  override func visit(heading: HeadingNode, _ context: Void) -> SatzResult<StreamSyntax> {
    let command: String
    switch heading.level {
    case 1: command = "section"
    case 2: command = "subsection"
    case 3: command = "subsubsection"
    default:
      return .failure(SatzError(.ExportLaTeXFailure))
    }
    return _composeControlSeq(command, heading.getChildren_readonly(), context)
  }

  override func visit(
    paragraph: ParagraphNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    let children = _visitChildren(paragraph, context)
    preconditionFailure("TODO: add newlines")
  }

  override func visit(root: RootNode, _ context: Void) -> SatzResult<StreamSyntax> {
    preconditionFailure()
  }

  override func visit(strong: StrongNode, _ context: Void) -> SatzResult<StreamSyntax> {
    _composeControlSeq("textbf", strong.getChildren_readonly(), context)
  }

  // MARK: - Math

  private func _composeControlSeq(_ command: String) -> SatzResult<StreamSyntax> {
    guard let commandToken = NameToken(command).map({ ControlSeqToken(name: $0) })
    else { return .failure(SatzError(.ExportLaTeXFailure)) }
    let controlSeq = ControlSeqSyntax(command: commandToken)
    return .success(StreamSyntax([.controlSeq(controlSeq)]))
  }

  private func _composeControlSeq<C: Collection<Node>>(
    _ command: String, _ components: C, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    guard let command = NameToken(command).map({ ControlSeqToken(name: $0) })
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    let arguments: Array<ComponentSyntax> =
      components
      .compactMap { component in component.accept(self, context).success() }
      .map { .group(GroupSyntax($0)) }

    guard arguments.count == components.count
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    let controlSeq = ControlSeqSyntax(command: command, arguments: arguments)
    return .success(StreamSyntax([.controlSeq(controlSeq)]))
  }

  private func _visitMath(
    command: String, _ node: MathNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    let components = node.enumerateComponents().map(\.content)
    return _composeControlSeq(command, components, context)
  }

  override func visit(accent: AccentNode, _ context: Void) -> SatzResult<StreamSyntax> {
    _visitMath(command: accent.accent.command, accent, context)
  }

  override func visit(attach: AttachNode, _ context: Void) -> SatzResult<StreamSyntax> {
    preconditionFailure()
  }

  override func visit(equation: EquationNode, _ context: Void) -> SatzResult<StreamSyntax>
  {
    preconditionFailure()
  }

  override func visit(fraction: FractionNode, _ context: Void) -> SatzResult<StreamSyntax>
  {
    _visitMath(command: fraction.subtype.command, fraction, context)
  }

  override func visit(
    leftRight: LeftRightNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    guard let nucleus = leftRight.nucleus.accept(self, context).success(),
      let leftDelimiter = leftRight.delimiters.open.getSyntax().success(),
      let rightDelimiter = leftRight.delimiters.close.getSyntax().success()
    else { return .failure(SatzError(.ExportLaTeXFailure)) }

    let left =
      StreamletSyntax(ControlSeqSyntax(command: .left, arguments: [leftDelimiter]))
    let right =
      StreamletSyntax(ControlSeqSyntax(command: .right, arguments: [rightDelimiter]))
    let stream: Array<StreamletSyntax> = [left] + nucleus.stream + [right]
    return .success(StreamSyntax(stream))
  }

  override func visit(
    mathAttributes: MathAttributesNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    _visitMath(command: mathAttributes.subtype.command, mathAttributes, context)
  }

  override func visit(
    mathExpression: MathExpressionNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    _composeControlSeq(mathExpression.mathExpression.command)
  }

  override func visit(
    mathOperator: MathOperatorNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    _composeControlSeq(mathOperator.mathOperator.command)
  }

  override func visit(
    mathVariant: MathVariantNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    _visitMath(command: mathVariant.styles.command, mathVariant, context)
  }

  override func visit(matrix: MatrixNode, _ context: Void) -> SatzResult<StreamSyntax> {
    preconditionFailure()
  }

  override func visit(
    namedSymbol: NamedSymbolNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    _composeControlSeq(namedSymbol.namedSymbol.command)
  }

  override func visit(overline: OverlineNode, _ context: Void) -> SatzResult<StreamSyntax>
  {
    _visitMath(command: overline.command, overline, context)
  }

  override func visit(
    overspreader: OverspreaderNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    _visitMath(command: overspreader.spreader.command, overspreader, context)
  }

  override func visit(radical: RadicalNode, _ context: Void) -> SatzResult<StreamSyntax> {
    preconditionFailure()
  }

  override func visit(
    underline: UnderlineNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    _visitMath(command: underline.command, underline, context)
  }

  override func visit(
    underspreader: UnderspreaderNode, _ context: Void
  ) -> SatzResult<StreamSyntax> {
    _visitMath(command: underspreader.spreader.command, underspreader, context)
  }

  override func visit(textMode: TextModeNode, _ context: Void) -> SatzResult<StreamSyntax>
  {
    _visitMath(command: textMode.command, textMode, context)
  }

}

private extension Delimiter {
  func getSyntax() -> SatzResult<ComponentSyntax> {
    switch self {
    case .char(let char):
      return .success(ComponentSyntax(CharSyntax(char)))
    case .empty:
      return .success(ComponentSyntax(CharSyntax(".")))
    case .symbol(let name):
      guard let nameToken = NameToken(name.command)
      else { return .failure(SatzError(.ExportLaTeXFailure)) }
      let controlSeq = ControlSeqToken(name: nameToken)
      return .success(ComponentSyntax(ControlSeqSyntax(command: controlSeq)))
    }
  }
}
