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

    struct PredicatedCounter: VisitorPlugin {
        private(set) var count = 0

        let predicate: (Expression) -> Bool

        init(_ predicate: @escaping (Expression) -> Bool) {
            self.predicate = predicate
        }

        mutating func visitExpression(_ expression: Expression, _ context: Void) {
            if predicate(expression) {
                count += 1
            }
        }
    }
}
