// Copyright 2024 Lie Yan

enum Nano {
    protocol NanoPass {
        associatedtype Input
        associatedtype Output

        static func process(_ input: Input) -> PassResult<Output>
    }

    struct PassError: Error { }
    typealias PassResult<T> = Result<T, PassError>

    typealias TemplateCalls = Set<TemplateName>

    static let allNanoPasses: [any NanoPass.Type] = [
        // in order of execution
        CheckWellFormedness.self,
        ExtractTemplateCalls.self,
        CheckDanglingTemplateCalls.self,
        TSortTemplates.self,
        InlineTemplateCalls.self,
        UnnestContents.self,
        MergeNeighbours.self,
        ConvertNamedVariables.self,
        LocateNamelessVariables.self,
        EmitCompiledTemplates.self, // final pass
    ]

    struct NanoPassDriver: NanoPass { // NanoPassDriver is not a nano pass
        typealias Input = [Template]
        typealias Output = [CompiledTemplate]

        static func process(_ input: [Template]) -> PassResult<[CompiledTemplate]> {
            PassResult.success(input)
                .flatMap(CheckWellFormedness.process)
                .flatMap(ExtractTemplateCalls.process)
                .flatMap(CheckDanglingTemplateCalls.process)
                .flatMap(TSortTemplates.process)
                .flatMap(InlineTemplateCalls.process)
                .flatMap(UnnestContents.process)
                .flatMap(MergeNeighbours.process)
                .flatMap(ConvertNamedVariables.process)
                .flatMap(LocateNamelessVariables.process)
                .flatMap(EmitCompiledTemplates.process)
        }
    }
}
