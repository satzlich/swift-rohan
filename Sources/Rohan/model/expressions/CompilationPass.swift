// Copyright 2024 Lie Yan

import Collections
import Foundation
import SatzAlgorithms

protocol CompilationPass {
    associatedtype Input
    associatedtype Output
}

struct TemplateWithUses {
    let template: Template
    let templateUses: [Identifier]

    var name: Identifier {
        template.name
    }
}

struct TemplateWithVariableUses {
    typealias VariableUseIndex = OrderedDictionary<Identifier, OrderedSet<TreePath>>

    let template: Template
    let variableUses: VariableUseIndex
}

// MARK: - AnalyzeTemplateUses

struct AnalyzeTemplateUses: CompilationPass {
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
        case .text:
            return
        case let .emphasis(emphasis):
            analyzeUses(emphasis.content, &uses)
        case let .heading(heading):
            analyzeUses(heading.content, &uses)
        case let .paragraph(paragraph):
            analyzeUses(paragraph.content, &uses)
        case let .equation(equation):
            analyzeUses(equation.content, &uses)
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
        _ content: Content,
        _ uses: inout Set<Identifier>
    ) {
        content.expressions.forEach { analyzeUses($0, &uses) }
    }
}

// MARK: - SortTopologically

struct SortTopologically: CompilationPass {
    typealias Input = [TemplateWithUses]
    typealias Output = [Template]

    static func process(_ templates: [TemplateWithUses]) -> [Template] {
        tsort(templates)
    }

    private static func tsort(_ templates: [TemplateWithUses]) -> [Template] {
        typealias TSorter = SatzAlgorithms.TSorter<Identifier>
        typealias Arc = TSorter.Arc

        let sorted = {
            let vertices = Set(templates.map { $0.name })
            let edges = templates.flatMap { template in
                template.templateUses.map { use in
                    Arc(use, template.name)
                }
            }
            return TSorter.tsort(vertices, edges)
        }()

        guard let sorted else {
            preconditionFailure("throw error")
        }

        let dict = Dictionary(uniqueKeysWithValues: zip(templates.map { $0.name },
                                                        templates.map { $0.template }))
        return sorted.map { dict[$0]! }
    }
}

struct ExpandAndCompact: CompilationPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func expandTemplates(_ templates: [Template]) -> [Template] {
        []
    }

    static func compactTemplate(_ template: Template) -> Template {
        template
    }
}

struct AnalyzeVariableUses: CompilationPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func indexVariableUses(_ template: Template) -> Template {
        template
    }
}

struct EliminateNames: CompilationPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func eliminateNames(_ template: Template) -> Template {
        template
    }
}

let compilationPasses: [any CompilationPass.Type] = [
    AnalyzeTemplateUses.self,
    SortTopologically.self,
    ExpandAndCompact.self,

    //
    AnalyzeVariableUses.self,
    EliminateNames.self,
]
