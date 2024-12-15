// Copyright 2024 Lie Yan

extension Narnia {
    struct AnalyseVariableUses: NanoPass {
        typealias Input = [Template]
        typealias Output = [AnnotatedTemplate<VariableUses>]

        func process(_ input: [Template]) -> PassResult<[AnnotatedTemplate<VariableUses>]> {
            let output = input.map { template in
                AnnotatedTemplate(template,
                                  annotation: Self.indexVariableUses(template))
            }
            return .success(output)
        }

        private static func indexVariableUses(_ template: Template) -> VariableUses {
            preconditionFailure()
        }
    }
}
