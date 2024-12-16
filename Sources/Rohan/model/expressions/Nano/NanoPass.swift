// Copyright 2024 Lie Yan

enum Nano {
    protocol NanoPass {
        associatedtype Input
        associatedtype Output

        func process(_ input: Input) -> PassResult<Output>
    }

    static let nanoPasses: [any NanoPass.Type] = [
        ExtractTemplateCalls.self,
        TSortTemplates.self,
        InlineTemplateCalls.self,
        UnnestContents.self,
        MergeNeighbours.self,
        //
        LocateNamedVariables.self,
        EliminateVariableName.self,
    ]

    struct AnnotatedTemplate<A> {
        typealias Annotation = A

        let canonical: Template
        let annotation: A

        var name: TemplateName {
            canonical.name
        }

        init(_ canonical: Template, annotation: A) {
            self.canonical = canonical
            self.annotation = annotation
        }
    }

    typealias TemplateCalls = Set<TemplateName>
}
