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
    typealias Output = [AnnotatedTemplate<TemplateUses>]

    func process(_ templates: [Template]) -> PassResult<[AnnotatedTemplate<TemplateUses>]> {
        let output = templates.map { template in
            AnnotatedTemplate(template,
                              annotation: Espresso
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
    typealias Input = [AnnotatedTemplate<TemplateUses>]
    typealias Output = [AnnotatedTemplate<TemplateUses>]

    func process(
        _ templates: [AnnotatedTemplate<TemplateUses>]
    ) -> PassResult<[AnnotatedTemplate<TemplateUses>]> {
        let output = Self.tsort(templates)

        if output.count != templates.count {
            return .failure(PassError())
        }
        return .success(output)
    }

    private static func tsort(
        _ templates: [AnnotatedTemplate<TemplateUses>]
    ) -> [AnnotatedTemplate<TemplateUses>] {
        typealias TSorter = SatzAlgorithms.TSorter<TemplateName>
        typealias Arc = TSorter.Arc

        let sorted = {
            let vertices = Set(templates.map { $0.name })
            let edges = templates.flatMap { template in
                template.annotation.map { use in
                    Arc(use, template.name)
                }
            }
            return TSorter.tsort(vertices, edges)
        }()

        guard let sorted else {
            return []
        }

        let dict = Dictionary(uniqueKeysWithValues: zip(templates.map { $0.name },
                                                        templates.map { $0 }))
        return sorted.map { dict[$0]! }
    }
}

struct ExpandAndCompact: CompilationPass {
    typealias Input = [AnnotatedTemplate<TemplateUses>]
    typealias Output = [Template]

    func process(_ input: [AnnotatedTemplate<TemplateUses>]) -> PassResult<[Template]> {
        let output = Self.expandTemplates(input)
        return .success(output)
    }

    static func expandTemplates(_ templates: [AnnotatedTemplate<TemplateUses>]) -> [Template] {
        /*
         partition templates into two groups and keep the order: `okay` and `bad`
         for t in `okay`:
            compact t
         process `okay` into dictionary
         for t in `bad`:
            expand t
            check t is okay
            compact t
            put t into `okay`
         */
        []
    }

    static func compactTemplate(_ template: Template) -> Template {
        preconditionFailure()
    }

    static func compactContent(_ content: Content) -> Content {
        preconditionFailure()
        /*
         for child in children:
            if child is content
                compact child
                inline child
            else
                keep it
         merge neiboring texts
         */
    }

    static func isApplyFree(_ template: AnnotatedTemplate<TemplateUses>) -> Bool {
        template.annotation.isEmpty
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
