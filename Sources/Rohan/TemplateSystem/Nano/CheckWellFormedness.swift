// Copyright 2024 Lie Yan

import Foundation

extension Nano {
    /**
     Check if the template is well-formed
     */
    struct CheckWellFormedness: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        static func process(_ input: [Template]) -> PassResult<[Template]> {
            if input.allSatisfy(isWellFormed) {
                return .success(input)
            }
            return .failure(PassError())
        }

        static func isWellFormed(_ template: Template) -> Bool {
            let countNamelessVariables = Espresso.CountingAction { expression in
                expression.type == .namelessVariable
            }

            let parameters = Set(template.parameters)
            let countFreeVariables = Espresso.CountingAction { expression in
                expression.type == .variable &&
                    !parameters.contains(expression.unwrapVariable()!.name)
            }

            let (namelessVariable, freeVariable) =
                Espresso.play(actions: countNamelessVariables,
                              countFreeVariables,
                              on: template.body)

            return namelessVariable.count == 0 &&
                freeVariable.count == 0
        }
    }
}
