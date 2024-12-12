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
                             templateUses: TemplateUseAnalyser.analyse(template))
        }
        return .success(output)
    }

    /**
     Analyses a template to determine which other templates it references.
     */
    private struct TemplateUseAnalyser {
        public static func analyse(_ template: Template) -> Set<TemplateName> {
            let context = Context(Set())
            Analyser().visitContent(template.body, context)
            return context.value
        }

        typealias Context = Ref<Set<TemplateName>>

        final class Analyser: ExpressionVisitor<Context> {
            override func visitApply(_ apply: Apply, _ context: Context) {
                context.value.insert(apply.templateName)
                super.visitApply(apply, context)
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
