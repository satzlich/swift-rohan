// Copyright 2024 Lie Yan

import Collections
import Foundation

struct TemplateWithUses {
    let template: Template
    let templateUses: Set<TemplateName>

    var name: TemplateName {
        template.name
    }
}

struct TemplateWithVariableUses {
    /**
     variable name -> variable use paths
     */
    typealias VariableUseIndex = OrderedDictionary<Identifier, OrderedSet<TreePath>>

    let template: Template
    let variableUses: VariableUseIndex

    var name: TemplateName {
        template.name
    }
}

struct NamelessTemplate {
    let parameterCount: Int
    let body: Content

    /**

     ## Conditions to check
     * contains no apply, named or nameless;
     * variables are nameless;
     * variable indices are in range

     */
    public static func validateBody(_ body: Content,
                                    _ parameterCount: Int) -> Bool
    {
        let applyCounter = ApplyCounter()
        let namedVariableCounter = NamedVariableCounter()
        let namelessVariable_OutOfRange_Counter =
            NamelessVariable_OutOfRange_Counter(parameterCount: parameterCount)

        ExpressionUtils.applyPlugins(
            [
                applyCounter,
                namedVariableCounter,
                namelessVariable_OutOfRange_Counter,
            ],
            body
        )

        return applyCounter.count == 0 &&
            namedVariableCounter.count == 0 &&
            namelessVariable_OutOfRange_Counter.count == 0
    }
}
