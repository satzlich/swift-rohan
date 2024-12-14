// Copyright 2024 Lie Yan

import Foundation

enum Espresso {
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

    /**
     Returns true if the expression is a variable with the given name
     */
    static func isVariable(_ expression: Expression, withName name: Identifier) -> Bool {
        switch expression {
        case let .variable(variable):
            return variable.name == name
        default:
            return false
        }
    }
}
