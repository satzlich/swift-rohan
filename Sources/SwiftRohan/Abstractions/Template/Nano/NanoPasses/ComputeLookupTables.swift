import OrderedCollections

extension Nano {
  /// argument index -> variable paths
  typealias LookupTable = Dictionary<Int, VariablePaths>

  struct ComputeLookupTables: NanoPass {
    typealias Input = Array<Template>
    typealias Output = Array<AnnotatedTemplate<LookupTable>>

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
      assertionFailure("The input must not contain apply")
    }

    override func visit(variable: VariableExpr, _ context: Context) {
      assertionFailure("The input must not contain variable")
    }

    override func visit(cVariable: CompiledVariableExpr, _ context: Context) {
      lookupTable[cVariable.argumentIndex, default: .init()].append(context)
    }

    // MARK: - Misc

    override func visit(counter: CounterExpr, _ context: TreePath) -> Void {
      // no-op as CounterExpr does not have children
    }

    override func visit(linebreak: LinebreakExpr, _ context: Context) -> Void {
      // no-op as LinebreakExpr does not have children
    }

    override func visit(text: TextExpr, _ context: Context) {
      // no-op as TextExpr does not have children
    }

    override func visit(unknown: UnknownExpr, _ context: Context) -> Void {
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

    override func visit(heading: HeadingExpr, _ context: Context) {
      _visitElement(heading, context)
    }

    override func visit(itemList: ItemListExpr, _ context: TreePath) {
      _visitElement(itemList, context)
    }

    override func visit(paragraph: ParagraphExpr, _ context: Context) {
      _visitElement(paragraph, context)
    }

    override func visit(parList: ParListExpr, _ context: Context) -> Void {
      _visitElement(parList, context)
    }

    override func visit(root: RootExpr, _ context: Context) -> Void {
      _visitElement(root, context)
    }

    override func visit(textStyles: TextStylesExpr, _ context: Context) -> Void {
      _visitElement(textStyles, context)
    }

    // MARK: - Math

    private func _visitMath<T: MathExpr>(_ math: T, _ context: Context) {
      let components = math.enumerateComponents()

      for (index, component) in components {
        let newContext = context + [.mathIndex(index)]
        component.accept(self, newContext)
      }
    }

    private func _visitArray<T: ArrayExpr>(_ array: T, _ context: Context) {
      for i in 0..<array.rowCount {
        for j in 0..<array.columnCount {
          let newContext = context + [.gridIndex(i, j)]
          array.get(i, j).accept(self, newContext)
        }
      }
    }

    override func visit(accent: AccentExpr, _ context: Context) -> Void {
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

    override func visit(leftRight: LeftRightExpr, _ context: Context) -> Void {
      _visitMath(leftRight, context)
    }

    override func visit(mathAttributes: MathAttributesExpr, _ context: Context) -> Void {
      _visitMath(mathAttributes, context)
    }

    override func visit(mathExpression: MathExpressionExpr, _ context: Context) -> Void {
      // no-op
    }

    override func visit(mathOperator: MathOperatorExpr, _ context: Context) -> Void {
      // no-op
    }

    override func visit(namedSymbol: NamedSymbolExpr, _ context: Context) -> Void {
      // no-op
    }

    override func visit(mathStyles: MathStylesExpr, _ context: Context) -> Void {
      _visitMath(mathStyles, context)
    }

    override func visit(matrix: MatrixExpr, _ context: Context) -> Void {
      _visitArray(matrix, context)
    }

    override func visit(multiline: MultilineExpr, _ context: Context) -> Void {
      _visitArray(multiline, context)
    }

    override func visit(radical: RadicalExpr, _ context: Context) -> Void {
      _visitMath(radical, context)
    }

    override func visit(textMode: TextModeExpr, _ context: Context) -> Void {
      _visitMath(textMode, context)
    }

    override func visit(underOver: UnderOverExpr, _ context: Context) -> Void {
      _visitMath(underOver, context)
    }
  }
}
