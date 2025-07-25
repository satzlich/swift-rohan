extension Nano {
  /// Convert (named) variables to compiled ones
  struct ConvertVariables: NanoPass {
    typealias Input = Array<Template>
    typealias Output = Array<Template>

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map(convertVariables(_:))
      return .success(output)
    }

    private static func convertVariables(_ template: Template) -> Template {
      let keyValues = template.parameters.enumerated().map { ($1, $0) }
      // name -> index
      let variableDict = Dictionary(uniqueKeysWithValues: keyValues)
      let rewriter = ConvertVariablesRewriter(variableDict: variableDict)
      let body = rewriter.rewrite(template.body, ())
      return template.with(body: body)
    }

    final class ConvertVariablesRewriter: ExpressionRewriter<Void> {
      let variableDict: Dictionary<Identifier, Int>

      init(variableDict: Dictionary<Identifier, Int>) {
        self.variableDict = variableDict
      }
      override func visit(variable: VariableExpr, _ context: Void) -> R {
        precondition(variableDict[variable.name] != nil)
        let index = variableDict[variable.name]!
        return CompiledVariableExpr(
          index, textStyles: variable.textStyles, variable.layoutType)
      }
    }
  }
}
