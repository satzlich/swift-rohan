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

    private final class BodyValidator: SimpleExpressionVisitor {
        public static func validateBody(_ body: Content,
                                        _ parameterCount: Int) -> Bool
        {
            // contains no apply, named and nameless;
            // variables are nameless;
            // variable indices are in range
            BodyValidator(parameterCount: parameterCount)
                .apply(body)
                .okay
        }

        var applyCount = 0 // named and nameless
        var namedVariableCount = 0
        var namelessVariable_OutOfRange_Count = 0
        let parameterCount: Int

        var okay: Bool {
            applyCount == 0 &&
                namedVariableCount == 0 &&
                namelessVariable_OutOfRange_Count == 0
        }

        init(parameterCount: Int) {
            self.parameterCount = parameterCount
        }

        // MARK: - Visitor

        override func visitApply(_ apply: Apply, _ context: Void) {
            applyCount += 1
            super.visitApply(apply, context)
        }

        override func visitNamelessApply(_ namelessApply: NamelessApply,
                                         _ context: Void)
        {
            applyCount += 1
            super.visitNamelessApply(namelessApply, context)
        }

        override func visitVariable(_ variable: Variable, _ context: Void) {
            namedVariableCount += 1
            super.visitVariable(variable, context)
        }

        override func visitNamelessVariable(_ namelessVariable: NamelessVariable,
                                            _ context: Void)
        {
            if namelessVariable.index >= parameterCount {
                namelessVariable_OutOfRange_Count += 1
            }
            super.visitNamelessVariable(namelessVariable, context)
        }
    }
}
