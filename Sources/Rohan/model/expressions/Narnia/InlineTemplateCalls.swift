// Copyright 2024 Lie Yan

import Algorithms
import Collections
import Foundation

extension Narnia {
    struct InlineTemplateCalls: NanoPass {
        typealias Input = [AnnotatedTemplate<TemplateCalls>]
        typealias Output = [Template]

        fileprivate typealias TemplateTable = OrderedDictionary<TemplateName, Template>

        func process(_ input: [AnnotatedTemplate<TemplateCalls>]) -> PassResult<[Template]> {
            let output = Self.processTemplates(input)
            return .success(output)
        }

        /**
         The whole process can be statically factored out. So we put it here.
         */
        private static func processTemplates(_ templates: [AnnotatedTemplate<TemplateCalls>]) -> [Template] {
            // 1) partition templates into two groups
            let (bad, okay) = templates.partitioned(by: { $0.annotation.isEmpty })

            // 2) put okay templates into dictionary
            var okayDict = TemplateTable(uniqueKeysWithValues: okay.map { ($0.name,
                                                                           $0.canonical) })

            // 3) process bad templates
            for t in bad {
                // a) expand t
                let expanded = inlineTemplateCalls(in: t.canonical, okayDict)
                // b) check t is okay
                assert(Espresso.countTemplateCalls(in: expanded.body) == 0)
                // d) put t into okay
                assert(okayDict[expanded.name] == nil)
                okayDict[expanded.name] = expanded
            }

            return okayDict.map { $0.value }
        }

        private static func inlineTemplateCalls(in template: Template,
                                                _ okayDict: TemplateTable) -> Template
        {
            let body = InlineTemplateCallsRewriter(templateTable: okayDict)
                .rewrite(template.body, ())
            return template.with(body: body)
        }

        private final class InlineTemplateCallsRewriter: ExpressionRewriter<Void> {
            fileprivate let templateTable: TemplateTable

            fileprivate init(templateTable: TemplateTable) {
                self.templateTable = templateTable
            }

            override func visitApply(_ apply: Apply, _ context: Void) -> R {
                precondition(templateTable[apply.templateName] != nil)

                let template = templateTable[apply.templateName]!
                assert(template.parameters.count == apply.arguments.count)

                let environment = Environment(uniqueKeysWithValues: zip(template.parameters,
                                                                        apply.arguments))
                let body = EvaluateExpressionRewriter(environment)                    .rewrite(template.body, ())

                return .content(body)
            }
        }

        private typealias Environment = Dictionary<Identifier, Content>

        /**
         Evaluate the expression under the given environment
         */
        private final class EvaluateExpressionRewriter: ExpressionRewriter<Void> {
            private let environment: Environment

            fileprivate init(_ environment: Environment) {
                self.environment = environment
            }

            override func visitVariable(_ variable: Variable, _ context: Void) -> R {
                precondition(environment[variable.name] != nil)
                return .content(environment[variable.name]!)
            }
        }
    }
}
