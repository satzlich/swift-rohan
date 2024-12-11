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

// MARK: - AnalyzeTemplateUses

struct AnalyzeTemplateUses: CompilePass {
    typealias Input = [Template]
    typealias Output = [TemplateWithUses]

    static func process(_ templates: [Template]) -> [TemplateWithUses] {
        templates.map { TemplateWithUses(template: $0, templateUses: analyzeUses($0)) }
    }

    /**
     Analyzes a template to determine which other templates it references.
     */
    private static func analyzeUses(_ template: Template) -> [Identifier] {
        var uses = Set<Identifier>()
        analyzeUses(template.body, &uses)
        assert(!uses.contains(template.name))
        return Array(uses)
    }

    private static func analyzeUses(_ expression: Expression, _ uses: inout Set<Identifier>) {
        switch expression {
        case let .apply(apply):
            uses.insert(apply.templateName)
            for argument in apply.arguments {
                analyzeUses(argument, &uses)
            }
        case .variable:
            return
        case .namelessApply:
            preconditionFailure("should not appear")
        case .namelessVariable:
            preconditionFailure("should not appear")
        case let .content(content):
            analyzeUses(content.expressions, &uses)
        case .text:
            return
        case let .emphasis(emphasis):
            analyzeUses(emphasis.expressions, &uses)
        case let .heading(heading):
            analyzeUses(heading.expressions, &uses)
        case let .paragraph(paragraph):
            analyzeUses(paragraph.expressions, &uses)
        case let .equation(equation):
            analyzeUses(equation.expressions, &uses)
        case let .fraction(fraction):
            analyzeUses(fraction.numerator, &uses)
            analyzeUses(fraction.denominator, &uses)
        case let .matrix(matrix):
            for row in matrix.rows {
                for element in row.elements {
                    analyzeUses(element, &uses)
                }
            }
        case let .scripts(scripts):
            scripts.subscript.map { analyzeUses($0, &uses) }
            scripts.superscript.map { analyzeUses($0, &uses) }
        }
    }

    private static func analyzeUses(
        _ expressions: [Expression],
        _ uses: inout Set<Identifier>
    ) {
        expressions.forEach { analyzeUses($0, &uses) }
    }
}

// MARK: - SortTopologically

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
