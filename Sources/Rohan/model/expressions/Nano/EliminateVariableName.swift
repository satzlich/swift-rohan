// Copyright 2024 Lie Yan

extension Nano {
    struct EliminateVariableName: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        func process(_ input: [Template]) -> PassResult<[Template]> {
            let output = input.map(Self.eliminateVariableName)
            return .success(output)
        }

        private static func eliminateVariableName(_ template: Template) -> Template {
            let keyValues = template.parameters.enumerated().map {
                index, value in (value, index)
            }
            let variableDict = Dictionary(uniqueKeysWithValues: keyValues)
            let body = EliminateVariableNameRewriter(variableDict: variableDict)
                .rewrite(content: template.body, ())

            return template.with(body: body)
        }

        final class EliminateVariableNameRewriter: ExpressionRewriter<Void> {
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
