// Copyright 2024-2025 Lie Yan

import OrderedCollections

extension Nano {
  /** argument index -> variable paths */
  typealias LookupTable = Dictionary<Int, VariablePaths>

  struct ComputeLookupTables: NanoPass {
    typealias Input = [Template]
    typealias Output = [AnnotatedTemplate<LookupTable>]

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map { template in
        AnnotatedTemplate(template, annotation: Self.computeLookupTable(for: template))
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

  /** Traverse the expression tree, and maintain the tree-path to the current node
   as context. */
  private final class BuildLookupVisitor: ExpressionVisitor<TreePath, Void> {
    typealias Context = TreePath

    private(set) var lookupTable = LookupTable()

    override func visit(apply: ApplyExpr, _ context: Context) {
      preconditionFailure("The input must not contain apply")
    }

    override func visit(variable: VariableExpr, _ context: Context) {
      preconditionFailure("The input must not contain variable")
    }

    override func visit(cVariable: CompiledVariableExpr, _ context: Context) {
      lookupTable[cVariable.argumentIndex, default: .init()].append(context)
    }

    override func visit(text: TextExpr, _ context: Context) {
      // do nothing
    }

    private func _visitElement(_ element: ElementExpr, _ context: Context) {
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

    override func visit(equation: EquationExpr, _ context: Context) {
      let newContext = context + [.mathIndex(.nucleus)]
      equation.nucleus.accept(self, newContext)
    }

    override func visit(fraction: FractionExpr, _ context: Context) {
      do {
        let newContext = context + [.mathIndex(.numerator)]
        fraction.numerator.accept(self, newContext)
      }
      do {
        let newContext = context + [.mathIndex(.denominator)]
        fraction.denominator.accept(self, newContext)
      }
    }

    override func visit(matrix: MatrixExpr, _ context: Context) {
      for i in 0..<matrix.rows.count {
        for j in 0..<matrix.rows[i].elements.count {
          let newContext = context + [.gridIndex(i, j)]
          visit(content: matrix.rows[i].elements[j], newContext)
        }
      }
    }

    override func visit(scripts: ScriptsExpr, _ context: Context) {
      if let subScript = scripts.subScript {
        let newContext = context + [.mathIndex(.subScript)]
        subScript.accept(self, newContext)
      }
      if let superScript = scripts.superScript {
        let newContext = context + [.mathIndex(.superScript)]
        superScript.accept(self, newContext)
      }
    }
  }
}
