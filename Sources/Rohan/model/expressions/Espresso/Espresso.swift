// Copyright 2024 Lie Yan

import Foundation

/**
 Types and utilities for `Expression`s
 */
enum Espresso {

    /**
     Prefer using `Espresso.counter(predicate:)` to this
     */
    struct PredicatedCounter<C>: ExpressionAction {
        private(set) var count = 0

        let predicate: (Expression, C) -> Bool

        init(_ predicate: @escaping (Expression, C) -> Bool) {
            self.predicate = predicate
        }

        mutating func onExpression(_ expression: Expression, _ context: C) {
            if predicate(expression, context) {
                count += 1
            }
        }
    }

    struct HandyAction<C>: ExpressionAction {
        let closure: (Expression, C) -> Void

        init(closure: @escaping (Expression, C) -> Void) {
            self.closure = closure
        }

        func onExpression(_ expression: Expression, _ context: C) {
            closure(expression, context)
        }
    }
}
