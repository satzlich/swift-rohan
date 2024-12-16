// Copyright 2024 Lie Yan

import Foundation

/**
 Types and utilities for `Expression`s
 */
enum Espresso {
    /**
     Play an action on a content
     */
    static func play<A>(action: A, on content: Content) -> A
        where A: ExpressionAction, A.Context == Void
    {
        let player = ActionPlayer(action)
        player.visit(content: content, ())
        return player.action
    }

    /**
     Play an action on a content
     */
    static func play(closure: @escaping (Expression, Void) -> Void, on content: Content) {
        _ = play(action: ClosureAction(closure), on: content)
    }

    /**

     - Complexity: O(n)
     */
    static func count(_ predicate: @escaping (Expression) -> Bool,
                      in content: Content) -> Int
    {
        var count = 0
        play(closure: { expression, _ in
                 if predicate(expression) {
                     count += 1
                 }
             },
             on: content)
        return count
    }

    /**
     Prefer using `Espresso.counter(predicate:)` to this
     */
    struct CountingAction<C>: ExpressionAction {
        private(set) var count = 0

        let predicate: (Expression, C) -> Bool

        init(_ predicate: @escaping (Expression) -> Bool)
            where C == Void
        {
            self.predicate = { expression, _ in predicate(expression) }
        }

        init(_ predicate: @escaping (Expression, C) -> Bool) {
            self.predicate = predicate
        }

        mutating func onExpression(_ expression: Expression, _ context: C) {
            if predicate(expression, context) {
                count += 1
            }
        }
    }

    struct ClosureAction<C>: ExpressionAction {
        let closure: (Expression, C) -> Void

        init(_ closure: @escaping (Expression, C) -> Void) {
            self.closure = closure
        }

        func onExpression(_ expression: Expression, _ context: C) {
            closure(expression, context)
        }
    }

    private final class ActionPlayer<A>: SimpleExpressionVisitor<A.Context>
    where A: ExpressionAction {
        typealias Context = A.Context

        private(set) var action: A

        init(_ action: A) {
            self.action = action
        }

        override func visit(expression: Expression, _ context: Context) {
            action.onExpression(expression, context)
            super.visit(expression: expression, context)
        }
    }
}
