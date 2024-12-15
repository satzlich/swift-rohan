// Copyright 2024 Lie Yan

enum Narnia {
    protocol NanoPass {
        associatedtype Input
        associatedtype Output

        func process(_ input: Input) -> PassResult<Output>
    }

    struct ConvertToNameless: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        func process(_ input: [Template]) -> PassResult<[Template]> {
            let output = input.map(Self.eliminateNames)
            return .success(output)
        }

        static func eliminateNames(_ template: Template) -> Template {
            preconditionFailure()
        }
    }

    static let compilationPasses: [any NanoPass.Type] = [
        AnalyseTemplateCalls.self,
        SortTopologically.self,
        InlineTemplateCalls.self,
        UnnestContents.self,
        MergeNeighbours.self,
        //
        AnalyseVariableUses.self,
        ConvertToNameless.self,
    ]
}
