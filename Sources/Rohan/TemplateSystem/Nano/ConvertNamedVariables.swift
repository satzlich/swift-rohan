// Copyright 2024-2025 Lie Yan

extension Nano {
  struct ConvertNamedVariables: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func process(_ input: [Template]) -> PassResult<[Template]> {
      let output = input.map(ConvertNamedVariables.convertNamedVariables(_:))
      return .success(output)
    }

    private static func convertNamedVariables(_ template: Template) -> Template {
      let keyValues = template.parameters.enumerated().map {
        index, value in (value, index)
      }
      let variableDict = Dictionary(uniqueKeysWithValues: keyValues)
      let body = ConvertNamedVariablesRewriter(variableDict: variableDict)
        .rewrite(content: template.body, ())

      return template.with(body: body)
    }

    final class ConvertNamedVariablesRewriter: ExpressionRewriter<Void> {
      let variableDict: [Identifier: Int]

      init(variableDict: [Identifier: Int]) {
        self.variableDict = variableDict
      }

      override func visit(variable: Variable, _ context: Void) -> R {
        precondition(variableDict[variable.name] != nil)
        let index = variableDict[variable.name]!
        return .namelessVariable(NamelessVariable(index))
      }
    }
  }
}
