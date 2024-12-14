// Copyright 2024 Lie Yan

import Foundation

/**
 Types and utilities for `Expression`s
 */
enum Espresso {
    static func counter(
        predicate: @escaping (Expression) -> Bool
    ) -> PredicatedCounter<Void> {
        counter(predicate: { expression, _ in predicate(expression) })
    }

    static func counter<C>(
        predicate: @escaping (Expression, C) -> Bool
    ) -> PredicatedCounter<C> {
        PredicatedCounter(predicate)
    }

    /**
     Prefer using `Espresso.counter(predicate:)` to this
     */
    struct PredicatedCounter<C>: VisitorPlugin {
        private(set) var count = 0

        let predicate: (Expression, C) -> Bool

        init(_ predicate: @escaping (Expression, C) -> Bool) {
            self.predicate = predicate
        }

        mutating func visitExpression(_ expression: Expression, _ context: C) {
            if predicate(expression, context) {
                count += 1
            }
        }
    }

    /**
     Returns true if the template is free of apply (named only)

     - Complexity: O(n)
     */
    static func countTemplateCalls(in content: Content) -> Int {
        plugAndPlay(counter(predicate: { $0.type == .apply }),
                    content)
            .count
    }
}
