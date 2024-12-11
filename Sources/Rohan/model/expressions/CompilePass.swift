// Copyright 2024 Lie Yan

import Collections
import Foundation

protocol CompilePass {
    associatedtype Input
    associatedtype Output
}

struct TemplateWithUses {
    let template: Template
    let templateUses: [Identifier]
}

struct TemplateWithVariableUses {
    typealias VariableUseIndex = OrderedDictionary<Identifier, OrderedSet<TreePath>>

    let template: Template
    let variableUses: VariableUseIndex
}

struct AnalyzeTemplateUses: CompilePass {
    typealias Input = [Template]
    typealias Output = [TemplateWithUses]

    /**
     Analyzes a template to determine which other templates it references.
     */
    static func analyzeUses(_ template: Template) -> [Identifier] {
        preconditionFailure("Not implemented")
    }
}

struct SortTopologically: CompilePass {
    typealias Input = [TemplateWithUses]
    typealias Output = [Template]

    static func topologicalSort(_ templates: [TemplateWithUses]) -> [Template] {
        []
    }
}

struct ExpandAndCompact: CompilePass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func expandTemplates(_ templates: [Template]) -> [Template] {
        []
    }

    static func compactTemplate(_ template: Template) -> Template {
        template
    }
}

struct AnalyzeVariableUses: CompilePass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func indexVariableUses(_ template: Template) -> Template {
        template
    }
}

struct EliminateNames: CompilePass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func eliminateNames(_ template: Template) -> Template {
        template
    }
}

let compilePasses: [any CompilePass.Type] = [
    AnalyzeTemplateUses.self,
    SortTopologically.self,
    ExpandAndCompact.self,

    //
    AnalyzeVariableUses.self,
    EliminateNames.self,
]
