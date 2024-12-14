// Copyright 2024 Lie Yan

import Algorithms
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
                              annotation: Self.templateUses(in: template))
        }
        return .success(output)
    }

    /**
     Returns the templates referenced by the template

     - Complexity: O(n)
     */
    static func templateUses(in template: Template) -> TemplateUses {
        /**
         Analyses a template to determine which other templates it references.
         */
        struct TemplateUseAnalyser: Espresso.VisitorPlugin {
            private(set) var templateUses: TemplateUses = []

            mutating func visitExpression(_ expression: Expression, _ context: Context) {
                switch expression {
                case let .apply(apply):
                    templateUses.insert(apply.templateName)
                default:
                    return
                }
            }
        }
        return Espresso
            .applyPlugin(TemplateUseAnalyser(), template.body)
            .templateUses
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

struct ExpandTemplates: CompilationPass {
    typealias Input = [AnnotatedTemplate<TemplateUses>]
    typealias Output = [Template]

    private typealias TemplateTable = OrderedDictionary<TemplateName, Template>

    func process(_ input: [AnnotatedTemplate<TemplateUses>]) -> PassResult<[Template]> {
        let output = Self.expandTemplates(input)
        return .success(output)
    }

    private static func expandTemplates(_ templates: [AnnotatedTemplate<TemplateUses>]) -> [Template] {
        // 1) partition templates into two groups
        let (okay, bad) = templates.partitioned(by: isApplyFree)

        // 2) put okay templates into dictionary
        var okayDict = TemplateTable(uniqueKeysWithValues: okay.map { ($0.name,
                                                                       $0.canonical) })

        // 3) expand bad templates
        for t in bad {
            // a) expand t
            let expanded = expandTemplate(t.canonical, okayDict)
            // b) check t is okay
            assert(TemplateUtils.isApplyFree(expanded))
            // d) put t into okay
            assert(okayDict[expanded.name] == nil)
            okayDict[expanded.name] = expanded
        }

        return okayDict.map { $0.value }
    }

    private static func expandTemplate(_ template: Template,
                                       _ okayDict: TemplateTable) -> Template
    {
        preconditionFailure()
    }

    private static func isApplyFree(_ template: AnnotatedTemplate<TemplateUses>) -> Bool {
        template.annotation.isEmpty
    }

    typealias VariableNameDict = Dictionary<Identifier, Identifier>

    final class ApplyExpander: ExpressionRewriter<Void> {
        override func visitApply(_ apply: Apply, _ context: Void) -> R {
            preconditionFailure()
        }
    }

    final class RenameVariables: ExpressionRewriter<Void> {
        private let variableNameDict: VariableNameDict

        init(_ variableNameDict: VariableNameDict) {
            self.variableNameDict = variableNameDict
        }

        override func visitVariable(_ variable: Variable, _ context: Void) -> R {
            let res = variable.with(name: variableNameDict[variable.name]!)
            return .variable(res)
        }
    }
}

struct CompactTemplates: CompilationPass {
    typealias Input = [Template]
    typealias Output = [Template]

    func process(_ input: [Template]) -> PassResult<[Template]> {
        let output = input.map { Self.compactTemplate($0) }
        return .success(output)
    }

    private static func compactTemplate(_ template: Template) -> Template {
        Template(name: template.name,
                 parameters: template.parameters,
                 body: compactContent(template.body))!
    }

    private static func compactContent(_ content: Content) -> Content {
        // 1) unnest contents
        let unnested = content.expressions.flatMap { expression in
            // for content, recurse and inline
            if case let .content(content) = expression {
                let compacted = compactContent(content)
                return compacted.expressions
            }
            // for other kinds, we must recurse
            else {
                // TODO: recurse
                preconditionFailure()
            }
        }

        // 2) merge texts
        let merged = unnested.reduce(into: [Expression]()) { acc, next in // acc for accumulated
            if let last = acc.last {
                if case let .text(lastText) = last,
                   case let .text(nextText) = next
                {
                    acc[acc.count - 1] = .text(lastText + nextText)
                }
                else {
                    acc.append(next)
                }
            }
            else {
                acc.append(next)
            }
        }

        return Content(expressions: merged)
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
    ExpandTemplates.self,
    CompactTemplates.self,
    //
    AnalyseVariableUses.self,
    EliminateNames.self,
]
