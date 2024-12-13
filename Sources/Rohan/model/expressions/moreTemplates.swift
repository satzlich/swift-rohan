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

        return applyCounter.applyCount == 0 &&
            namedVariableCounter.namedVariableCount == 0 &&
            namelessVariable_OutOfRange_Counter.namelessVariable_OutOfRange_Count == 0
    }
}

final class ApplyCounter: ExpressionVisitorPlugin<Void> {
    private(set) var applyCount = 0

    override func visitApply(_ apply: Apply, _ context: Void) {
        applyCount += 1
        super.visitApply(apply, context)
    }

    override func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Void) {
        applyCount += 1
        super.visitNamelessApply(namelessApply, context)
    }
}

final class NamedVariableCounter: ExpressionVisitorPlugin<Void> {
    private(set) var namedVariableCount = 0

    override func visitVariable(_ variable: Variable, _ context: Void) {
        namedVariableCount += 1
        super.visitVariable(variable, context)
    }
}

final class NamelessVariable_OutOfRange_Counter: ExpressionVisitorPlugin<Void> {
    let parameterCount: Int

    private(set) var namelessVariable_OutOfRange_Count = 0

    init(parameterCount: Int) {
        self.parameterCount = parameterCount
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
