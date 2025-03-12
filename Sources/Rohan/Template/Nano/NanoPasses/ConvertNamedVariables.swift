// Copyright 2024-2025 Lie Yan

extension Nano {
  struct ConvertNamedVariables: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map(ConvertNamedVariables.convertNamedVariables(_:))
      return .success(output)
    }

    private static func convertNamedVariables(_ template: Template) -> Template {
      let keyValues = template.parameters.enumerated().map { ($1, $0) }
      // name -> index
      let variableDict = Dictionary(uniqueKeysWithValues: keyValues)
      let rewriter = ConvertNamedVariablesRewriter(variableDict: variableDict)
      let body = rewriter.rewrite(template.body, ())
      return template.with(body: body)
    }

    final class ConvertNamedVariablesRewriter: ExpressionRewriter<Void> {
      let variableDict: [Identifier: Int]

      init(variableDict: [Identifier: Int]) {
        self.variableDict = variableDict
      }
      override func visit(variable: VariableExpr, _ context: Void) -> R {
        precondition(variableDict[variable.name] != nil)
        let index = variableDict[variable.name]!
        return UnnamedVariableExpr(index)
      }
    }
  }
}
