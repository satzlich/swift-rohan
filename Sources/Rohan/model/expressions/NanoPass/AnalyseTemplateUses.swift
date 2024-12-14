// Copyright 2024 Lie Yan

import Algorithms
import Collections
import Foundation

struct AnalyseTemplateUses: NanoPass {
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
