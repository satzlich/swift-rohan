// Copyright 2024 Lie Yan

import Algorithms
import Collections
import Foundation

extension Narnia {
    struct AnalyseTemplateCalls: NanoPass {
        typealias Input = [Template]
        typealias Output = [AnnotatedTemplate<TemplateCalls>]

        func process(_ templates: [Template]) -> PassResult<[AnnotatedTemplate<TemplateCalls>]> {
            let output = templates.map { template in
                AnnotatedTemplate(template,
                                  annotation: Self.analyseTemplateCalls(in: template))
            }
            return .success(output)
        }

        /**
         Returns the templates referenced by the template

         - Complexity: O(n)
         */
        static func analyseTemplateCalls(in template: Template) -> TemplateCalls {
            /**
             Analyses a template to determine which other templates it calls.
             */
            struct TemplateUseAnalyser: Espresso.VisitorPlugin {
                private(set) var templateCalls: TemplateCalls = []

                mutating func visitExpression(_ expression: Expression, _ context: Void) {
                    switch expression {
                    case let .apply(apply):
                        templateCalls.insert(apply.templateName)
                    default:
                        return
                    }
                }
            }
            return Espresso
                .plugAndPlay(TemplateUseAnalyser(), template.body)
                .templateCalls
        }
    }
}
