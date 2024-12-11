// Copyright 2024 Lie Yan

import Collections
import Foundation

protocol CompilePass {
}

struct AnalyzeTemplateUses: CompilePass {
    /**
     Analyzes a template to determine which other templates it references.
     */
    static func analyzeUses(_ template: Template) -> [Identifier] {
        preconditionFailure("Not implemented")
    }
}

struct SortTopologically: CompilePass {
    typealias AnnotatedTemplate = (template: Template, uses: [Identifier])

    static func topologicalSort(_ templates: [AnnotatedTemplate]) -> [Template] {
        []
    }
}

struct ExpandAndCompact: CompilePass {
    static func expandTemplates(_ templates: [Template]) -> [Template] {
        []
    }

    static func compactTemplate(_ template: Template) -> Template {
        template
    }
}

struct EliminateNames: CompilePass {
    static func eliminateNames(_ template: Template) -> Template {
        template
    }
}

struct AnalyzeVariableUses: CompilePass {
    typealias IndexData = OrderedDictionary<Int, OrderedSet<TreePath>>

    static func indexVariableUses(_ template: Template) -> Template {
        template
    }
}

let compilePasses: [any CompilePass.Type] = [
    AnalyzeTemplateUses.self,
    SortTopologically.self,
    ExpandAndCompact.self,
    EliminateNames.self,
    AnalyzeVariableUses.self,
]
