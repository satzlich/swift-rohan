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

    public static func validateBody(_ body: Content,
                                    _ parameterCount: Int) -> Bool
    {
        BodyValidator(parameterCount: parameterCount)
            .invoke(with: body)
            .okay
    }

    /**

     ## Conditions to check
     * contains no apply, named or nameless;
     * variables are nameless;
     * variable indices are in range

     */
    final class BodyValidator: SimpleExpressionVisitor {
        init(parameterCount: Int) {
            self.parameterCount = parameterCount
        }

        // MARK: - State

        private var _applyCount = 0 // named and nameless
        private var _namedVariableCount = 0
        private var _namelessVariable_OutOfRange_Count = 0
        let parameterCount: Int

        var okay: Bool {
            _applyCount == 0 &&
                _namedVariableCount == 0 &&
                _namelessVariable_OutOfRange_Count == 0
        }

        // MARK: - Visitor

        override func visitApply(_ apply: Apply, _ context: Void) {
            _applyCount += 1
            super.visitApply(apply, context)
        }

        override func visitNamelessApply(_ namelessApply: NamelessApply,
                                         _ context: Void)
        {
            _applyCount += 1
            super.visitNamelessApply(namelessApply, context)
        }

        override func visitVariable(_ variable: Variable, _ context: Void) {
            _namedVariableCount += 1
            super.visitVariable(variable, context)
        }

        override func visitNamelessVariable(_ namelessVariable: NamelessVariable,
                                            _ context: Void)
        {
            if namelessVariable.index >= parameterCount {
                _namelessVariable_OutOfRange_Count += 1
            }
            super.visitNamelessVariable(namelessVariable, context)
        }
    }
}
