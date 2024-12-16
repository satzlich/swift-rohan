// Copyright 2024 Lie Yan

enum Nano {
    protocol NanoPass {
        associatedtype Input
        associatedtype Output

        func process(_ input: Input) -> PassResult<Output>
    }

    static let nanoPasses: [any NanoPass.Type] = [
        ExtractTemplateCalls.self,
        SortTopologically.self,
        InlineTemplateCalls.self,
        UnnestContents.self,
        MergeNeighbours.self,
        //
        IndexVariableUses.self,
        ConvertToNamelessVariables.self,
    ]
}
