// Copyright 2024 Lie Yan

import Collections
import Foundation
import SatzAlgorithms

protocol CompilationPass {
    associatedtype Input
    associatedtype Output

    func process(_ input: Input) -> PassResult<Output>
}

// MARK: - AnalyseTemplateUses

struct AnalyseTemplateUses: CompilationPass {
    typealias Input = [Template]
    typealias Output = [TemplateWithUses]

    func process(_ templates: [Template]) -> PassResult<[TemplateWithUses]> {
        let output = templates.map { template in
            TemplateWithUses(template: template,
                             templateUses: Espresso
                                 .applyPlugin(TemplateUseAnalyser(), template.body)
                                 .templateUses)
        }
        return .success(output)
    }

    /**
     Analyses a template to determine which other templates it references.
     */
    struct TemplateUseAnalyser: Espresso.VisitorPlugin {
        private(set) var templateUses: Set<TemplateName> = []

        mutating func visitExpression(_ expression: Expression, _ context: Context) {
            switch expression {
            case let .apply(apply):
                templateUses.insert(apply.templateName)
            default:
                return
            }
        }
    }
}

// MARK: - SortTopologically

struct SortTopologically: CompilationPass {
    typealias Input = [TemplateWithUses]
    typealias Output = [Template]

    func process(_ templates: [TemplateWithUses]) -> PassResult<[Template]> {
        let output = Self.tsort(templates)

        if output.count != templates.count {
            return .failure(PassError())
        }
        return .success(output)
    }

    private static func tsort(_ templates: [TemplateWithUses]) -> [Template] {
        typealias TSorter = SatzAlgorithms.TSorter<TemplateName>
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
            return []
        }

        let dict = Dictionary(uniqueKeysWithValues: zip(templates.map { $0.name },
                                                        templates.map { $0.template }))
        return sorted.map { dict[$0]! }
    }
}

struct ExpandAndCompact: CompilationPass {
    typealias Input = [Template]
    typealias Output = [Template]

    func process(_ input: [Template]) -> PassResult<[Template]> {
        let output = Self.expandTemplates(input)
        return .success(output)
    }

    static func expandTemplates(_ templates: [Template]) -> [Template] {
        []
    }

    static func compactTemplate(_ template: Template) -> Template {
        template
    }
}

struct AnalyseVariableUses: CompilationPass {
    typealias Input = [Template]
    typealias Output = [Template]

    func process(_ input: [Template]) -> PassResult<[Template]> {
        let output = [Template]()
        return .success(output)
    }

    static func indexVariableUses(_ template: Template) -> Template {
        template
    }
}

struct EliminateNames: CompilationPass {
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

let compilationPasses: [any CompilationPass.Type] = [
    AnalyseTemplateUses.self,
    SortTopologically.self,
    ExpandAndCompact.self,

    //
    AnalyseVariableUses.self,
    EliminateNames.self,
]
