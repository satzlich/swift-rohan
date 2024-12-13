// Copyright 2024 Lie Yan

import Foundation

/**
 Expression Plugin Library
 */
enum EPL {
    struct ApplyCounter: ExpressionPlugin {
        private(set) var count = 0

        mutating func visitApply(_ apply: Apply, _ context: Void) {
            count += 1
        }
    }

    struct NamelessApplyCounter: ExpressionPlugin {
        private(set) var count = 0

        mutating func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Void) {
            count += 1
        }
    }

    struct VariableCounter: ExpressionPlugin {
        private(set) var count = 0

        mutating func visitVariable(_ variable: Variable, _ context: Void) {
            count += 1
        }
    }

    struct NamelessVariableCounter: ExpressionPlugin {
        private(set) var count = 0

        mutating func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Void) {
            count += 1
        }
    }

    struct ParticularVariableCounter: ExpressionPlugin {
        private(set) var count = 0

        let variableName: Identifier

        init(_ variableName: Identifier) {
            self.variableName = variableName
        }

        mutating func visitVariable(_ variable: Variable, _ context: Context) {
            if variable.name == variableName {
                count += 1
            }
        }
    }
}
