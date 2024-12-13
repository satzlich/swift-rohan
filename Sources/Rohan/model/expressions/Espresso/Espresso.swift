// Copyright 2024 Lie Yan

import Foundation

enum Espresso {
    /**
     Convenience function to apply a visitor
     */
    static func applyVisitor<V>(_ visitor: V, _ content: Content) -> V
    where V: ExpressionVisitor<Void> {
        visitor.visitContent(content, ())
        return visitor
    }

    // MARK: -

    struct ApplyCounter: VisitorPlugin {
        private(set) var count = 0

        mutating func visitApply(_ apply: Apply, _ context: Void) {
            count += 1
        }
    }

    struct NamelessApplyCounter: VisitorPlugin {
        private(set) var count = 0

        mutating func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Void) {
            count += 1
        }
    }

    struct VariableCounter: VisitorPlugin {
        private(set) var count = 0

        mutating func visitVariable(_ variable: Variable, _ context: Void) {
            count += 1
        }
    }

    struct NamelessVariableCounter: VisitorPlugin {
        private(set) var count = 0

        mutating func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Void) {
            count += 1
        }
    }

    struct ParticularVariableCounter: VisitorPlugin {
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
