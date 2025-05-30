// Copyright 2024-2025 Lie Yan

import OrderedCollections

extension Nano {
  /// argument index -> variable paths
  typealias LookupTable = Dictionary<Int, VariablePaths>

  struct ComputeLookupTables: NanoPass {
    typealias Input = [Template]
    typealias Output = [AnnotatedTemplate<LookupTable>]

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map { template in
        AnnotatedTemplate(template, annotation: computeLookupTable(for: template))
      }
      return .success(output)
    }

    private static func computeLookupTable(for template: Template) -> LookupTable {
      let visitor = BuildLookupVisitor()
      for (i, expression) in template.body.enumerated() {
        expression.accept(visitor, [.index(i)])
      }
      // check the uniqueness of variable paths
      for variablePaths in visitor.lookupTable.values {
        let set = Set(variablePaths)
        assert(set.count == variablePaths.count)
      }

      return visitor.lookupTable
    }
  }

  /// Traverse the expression tree, and maintain the tree-path to the current node
  /// as context.
  private final class BuildLookupVisitor: ExprVisitor<TreePath, Void> {
    typealias Context = TreePath

    private(set) var lookupTable = LookupTable()

    // MARK: - Template

    override func visit(apply: ApplyExpr, _ context: Context) {
      preconditionFailure("The input must not contain apply")
    }

    override func visit(variable: VariableExpr, _ context: Context) {
      preconditionFailure("The input must not contain variable")
    }

    override func visit(cVariable: CompiledVariableExpr, _ context: Context) {
      lookupTable[cVariable.argumentIndex, default: .init()].append(context)
    }

    // MARK: - Misc

    override func visit(linebreak: LinebreakExpr, _ context: TreePath) -> Void {
      // no-op as LinebreakExpr does not have children
    }

    override func visit(text: TextExpr, _ context: Context) {
      // no-op as TextExpr does not have children
    }

    override func visit(unknown: UnknownExpr, _ context: TreePath) -> Void {
      // no-op as UnknownExpr does not have children
    }

    // MARK: - Element

    private func _visitElement<T: ElementExpr>(_ element: T, _ context: Context) {
      let expressions = element.children
      for index in 0..<expressions.count {
        let newContext = context + [.index(index)]
        expressions[index].accept(self, newContext)
      }
    }

    override func visit(content: ContentExpr, _ context: Context) {
      _visitElement(content, context)
    }

    override func visit(emphasis: EmphasisExpr, _ context: Context) {
      _visitElement(emphasis, context)
    }

    override func visit(heading: HeadingExpr, _ context: Context) {
      _visitElement(heading, context)
    }

    override func visit(paragraph: ParagraphExpr, _ context: Context) {
      _visitElement(paragraph, context)
    }

    override func visit(root: RootExpr, _ context: TreePath) -> Void {
      _visitElement(root, context)
    }

    override func visit(strong: StrongExpr, _ context: TreePath) -> Void {
      _visitElement(strong, context)
    }

    // MARK: - Math

    private func _visitMath<T: MathExpr>(_ math: T, _ context: Context) {
      let components = math.enumerateComponents()

      for (index, component) in components {
        let newContext = context + [.mathIndex(index)]
        component.accept(self, newContext)
      }
    }

    override func visit(accent: AccentExpr, _ context: TreePath) -> Void {
      _visitMath(accent, context)
    }

    override func visit(attach: AttachExpr, _ context: Context) {
      _visitMath(attach, context)
    }

    override func visit(equation: EquationExpr, _ context: Context) {
      _visitMath(equation, context)
    }

    override func visit(fraction: FractionExpr, _ context: Context) {
      _visitMath(fraction, context)
    }

    override func visit(leftRight: LeftRightExpr, _ context: TreePath) -> Void {
      _visitMath(leftRight, context)
    }

    override func visit(mathAttributes: MathAttributesExpr, _ context: TreePath) -> Void {
      _visitMath(mathAttributes, context)
    }

    override func visit(mathExpression: MathExpressionExpr, _ context: TreePath) -> Void {
      // no-op
    }

    override func visit(mathOperator: MathOperatorExpr, _ context: TreePath) -> Void {
      // no-op
    }

    override func visit(namedSymbol: NamedSymbolExpr, _ context: TreePath) -> Void {
      // no-op
    }

    override func visit(mathVariant: MathVariantExpr, _ context: TreePath) -> Void {
      _visitMath(mathVariant, context)
    }

    override func visit(matrix: MatrixExpr, _ context: Context) {
      for i in 0..<matrix.rowCount {
        for j in 0..<matrix.columnCount {
          let newContext = context + [.gridIndex(i, j)]
          matrix.get(i, j).accept(self, newContext)
        }
      }
    }

//    override func visit(overline: OverlineExpr, _ context: TreePath) -> Void {
//      _visitMath(overline, context)
//    }

    override func visit(overspreader: OverspreaderExpr, _ context: TreePath) -> Void {
      _visitMath(overspreader, context)
    }

    override func visit(radical: RadicalExpr, _ context: TreePath) -> Void {
      _visitMath(radical, context)
    }

    override func visit(textMode: TextModeExpr, _ context: TreePath) -> Void {
      _visitMath(textMode, context)
    }

//    override func visit(underline: UnderlineExpr, _ context: TreePath) -> Void {
//      _visitMath(underline, context)
//    }

    override func visit(underspreader: UnderspreaderExpr, _ context: TreePath) -> Void {
      _visitMath(underspreader, context)
    }
  }
}
