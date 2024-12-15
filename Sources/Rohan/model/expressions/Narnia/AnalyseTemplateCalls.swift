// Copyright 2024 Lie Yan

import Algorithms
import Collections
import Foundation

extension Narnia {
    struct AnalyseTemplateCalls: NanoPass {
        typealias Input = [Template]
        typealias Output = [AnnotatedTemplate<TemplateCalls>]

        func process(input: [Template]) -> PassResult<[AnnotatedTemplate<TemplateCalls>]> {
            let output = input.map { template in
                AnnotatedTemplate(template,
                                  annotation: Self.analyseTemplateCalls(in: template))
            }
            return .success(output)
        }

        /**
         Returns the templates referenced by the template

         - Complexity: O(n)
         */
        private static func analyseTemplateCalls(in template: Template) -> TemplateCalls {
            Espresso
                .play(action: TemplateUseAnalyser(), on: template.body)
                .templateCalls
        }

        /**
         Analyses a template to determine which other templates it calls.
         */
        private struct TemplateUseAnalyser: Espresso.ExpressionAction {
            private(set) var templateCalls: TemplateCalls = []

            mutating func onExpression(_ expression: Expression, _ context: Void) {
                switch expression {
                case let .apply(apply):
                    templateCalls.insert(apply.templateName)
                default:
                    return
                }
            }
        }
    }
}
