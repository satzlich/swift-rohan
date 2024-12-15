// Copyright 2024 Lie Yan

import Foundation

/**
 Types and utilities for `Expression`s
 */
enum Espresso {
    /**

     - Complexity: O(n)
     */
    static func count(_ predicate: @escaping (Expression) -> Bool,
                      in content: Content) -> Int
    {
        play(action: counter(predicate: predicate),
             on: content)
            .count
    }

    static func counter(
        predicate: @escaping (Expression) -> Bool
    ) -> PredicatedCounter<Void> {
        PredicatedCounter { expression, _ in predicate(expression) }
    }

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
}
