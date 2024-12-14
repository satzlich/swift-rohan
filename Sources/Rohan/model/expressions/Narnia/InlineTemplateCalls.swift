// Copyright 2024 Lie Yan

import Algorithms
import Collections
import Foundation

extension Narnia {
    struct InlineTemplateCalls: NanoPass {
        typealias Input = [AnnotatedTemplate<TemplateUses>]
        typealias Output = [Template]

        fileprivate typealias TemplateTable = OrderedDictionary<TemplateName, Template>

        func process(_ input: [AnnotatedTemplate<TemplateUses>]) -> PassResult<[Template]> {
            let output = Self.processTemplates(input)
            return .success(output)
        }

        private static func processTemplates(_ templates: [AnnotatedTemplate<TemplateUses>]) -> [Template] {
            // 1) partition templates into two groups
            let (bad, okay) = templates.partitioned(by: { $0.annotation.isEmpty })

            // 2) put okay templates into dictionary
            var okayDict = TemplateTable(uniqueKeysWithValues: okay.map { ($0.name,
                                                                           $0.canonical) })

            // 3) process bad templates
            for t in bad {
                // a) expand t
                let expanded = processTemplate(t.canonical, okayDict)
                // b) check t is okay
                assert(TemplateUtils.isApplyFree(expanded))
                // d) put t into okay
                assert(okayDict[expanded.name] == nil)
                okayDict[expanded.name] = expanded
            }

            return okayDict.map { $0.value }
        }

        private static func processTemplate(_ template: Template,
                                            _ okayDict: TemplateTable) -> Template
        {
            let body = InlineTemplateCallsRewriter(templateTable: okayDict).rewrite(template.body, ())
            return Template(name: template.name,
                            parameters: template.parameters,
                            body: body.unwrapContent()!)!
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

                let variableValueDict =
                    VariableValueDict(uniqueKeysWithValues: zip(template.parameters,
                                                                apply.arguments))
                let body = InlineVariableValuesRewriter(variableValueDict)
                    .rewrite(template.body, ())
                return .content(body.unwrapContent()!)
            }
        }

        private typealias VariableValueDict = Dictionary<Identifier, Content>

        private final class InlineVariableValuesRewriter: ExpressionRewriter<Void> {
            private let variableValueDict: VariableValueDict

            fileprivate init(_ variableNameDict: VariableValueDict) {
                self.variableValueDict = variableNameDict
            }

            override func visitVariable(_ variable: Variable, _ context: Void) -> R {
                precondition(variableValueDict[variable.name] != nil)
                return .content(variableValueDict[variable.name]!)
            }
        }
    }
}
