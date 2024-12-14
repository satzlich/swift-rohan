// Copyright 2024 Lie Yan

import Algorithms
import Collections
import Foundation
import SatzAlgorithms

protocol NanoPass {
    associatedtype Input
    associatedtype Output

    func process(_ input: Input) -> PassResult<Output>
}

struct AnalyseVariableUses: NanoPass {
    typealias Input = [Template]
    typealias Output = [AnnotatedTemplate<VariableUses>]

    func process(_ input: [Template]) -> PassResult<[AnnotatedTemplate<VariableUses>]> {
        let output = [AnnotatedTemplate<VariableUses>]()
        return .success(output)
    }

    static func indexVariableUses(_ template: Template) -> VariableUses {
        preconditionFailure()
    }
}

struct EliminateNames: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    func process(_ input: [Template]) -> PassResult<[Template]> {
        let output = [Template]()
        return .success(output)
    }

    static func eliminateNames(_ template: Template) -> Template {
        template
    }
}

let compilationPasses: [any NanoPass.Type] = [
    AnalyseTemplateUses.self,
    SortTopologically.self,
    ExpandTemplates.self,
    CompactTemplates.self,
    //
    AnalyseVariableUses.self,
    EliminateNames.self,
]
