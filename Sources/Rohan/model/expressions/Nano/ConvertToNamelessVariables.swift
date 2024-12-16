// Copyright 2024 Lie Yan

extension Nano {
    struct ConvertToNamelessVariables: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        func process(_ input: [Template]) -> PassResult<[Template]> {
            let output = input.map(Self.eliminateVariableNames)
            return .success(output)
        }

        private static func eliminateVariableNames(_ template: Template) -> Template {
            let keyValues = template.parameters.enumerated().map {
                index, value in (value, index)
            }
            let variableDict = Dictionary(uniqueKeysWithValues: keyValues)
            let body = ConvertToNamelessVariablesRewriter(variableDict: variableDict)
                .rewrite(content: template.body, ())

            return template.with(body: body)
        }

        final class ConvertToNamelessVariablesRewriter: ExpressionRewriter<Void> {
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
