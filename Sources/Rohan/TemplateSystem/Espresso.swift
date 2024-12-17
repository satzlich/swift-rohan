// Copyright 2024 Lie Yan

import Foundation

/**
 Simple actions on expressions and utilities for playing them
 */
enum Espresso {
    /**
     An action that can be played on an expression
     */
    protocol ExpressionAction<Context> {
        associatedtype Context = Void

        mutating func onExpression(_ expression: Expression, _ context: Context)
    }

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

    static func play<A0, A1>(actions a0: A0, _ a1: A1,
                             on content: Content) -> (A0, A1)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A0.Context == Void,
        A0.Context == A1.Context
    {
        let group = group(actions: a0, a1)
        let result = play(action: group, on: content)
        return ungroup(result)
    }

    static func play<A0, A1, A2>(actions a0: A0, _ a1: A1, _ a2: A2,
                                 on content: Content) -> (A0, A1, A2)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A0.Context == Void,
        A0.Context == A1.Context,
        A0.Context == A2.Context
    {
        let group = group(actions: a0, a1, a2)
        let result = play(action: group, on: content)
        return ungroup(result)
    }

    static func play<A0, A1, A2, A3>(actions a0: A0, _ a1: A1, _ a2: A2, _ a3: A3,
                                     on content: Content) -> (A0, A1, A2, A3)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A0.Context == Void,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context
    {
        let group = group(actions: a0, a1, a2, a3)
        let result = play(action: group, on: content)
        return ungroup(result)
    }

    static func play<A0, A1, A2, A3, A4>(actions a0: A0, _ a1: A1, _ a2: A2, _ a3: A3, _ a4: A4,
                                         on content: Content) -> (A0, A1, A2, A3, A4)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A0.Context == Void,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context
    {
        let group = group(actions: a0, a1, a2, a3, a4)
        let result = play(action: group, on: content)
        return ungroup(result)
    }

    static func play<A0, A1, A2, A3, A4, A5>(actions a0: A0, _ a1: A1, _ a2: A2, _ a3: A3, _ a4: A4, _ a5: A5,
                                             on content: Content) -> (A0, A1, A2, A3, A4, A5)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A5: ExpressionAction,
        A0.Context == Void,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context,
        A0.Context == A5.Context
    {
        let group = group(actions: a0, a1, a2, a3, a4, a5)
        let result = play(action: group, on: content)
        return ungroup(result)
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
        play(action: CountingAction(predicate), on: content).count
    }

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

    // MARK: - ActionGroup

    private struct ActionGroup<A, B>: ExpressionAction
        where A: ExpressionAction,
        B: ExpressionAction,
        A.Context == B.Context
    {
        typealias Context = A.Context

        private(set) var actions: (A, B)

        init(_ a: A, _ b: B) {
            self.actions = (a, b)
        }

        mutating func onExpression(_ expression: Expression, _ context: Context) {
            actions.0.onExpression(expression, context)
            actions.1.onExpression(expression, context)
        }
    }

    private typealias ActionGroup2<A0, A1> = ActionGroup<A0, A1>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A0.Context == A1.Context
    /*
     Prefer tail recursion
     */
    private typealias ActionGroup3<A0, A1, A2> = ActionGroup<A0, ActionGroup2<A1, A2>>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context
    private typealias ActionGroup4<A0, A1, A2, A3> = ActionGroup<A0, ActionGroup3<A1, A2, A3>>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context
    private typealias ActionGroup5<A0, A1, A2, A3, A4> = ActionGroup<A0, ActionGroup4<A1, A2, A3, A4>>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context
    private typealias ActionGroup6<A0, A1, A2, A3, A4, A5> = ActionGroup<A0, ActionGroup5<A1, A2, A3, A4, A5>>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A5: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context,
        A0.Context == A5.Context

    // MARK: - Utility

    private static func group<A0, A1>(
        actions a0: A0, _ a1: A1
    ) -> ActionGroup2<A0, A1>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A0.Context == A1.Context
    {
        ActionGroup(a0, a1)
    }

    private static func group<A0, A1, A2>(
        actions a0: A0, _ a1: A1, _ a2: A2
    ) -> ActionGroup3<A0, A1, A2>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context
    {
        ActionGroup3(a0, group(actions: a1, a2))
    }

    private static func group<A0, A1, A2, A3>(
        actions a0: A0, _ a1: A1, _ a2: A2, _ a3: A3
    ) -> ActionGroup4<A0, A1, A2, A3>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context
    {
        ActionGroup4(a0, group(actions: a1, a2, a3))
    }

    private static func group<A0, A1, A2, A3, A4>(
        actions a0: A0, _ a1: A1, _ a2: A2, _ a3: A3, _ a4: A4
    ) -> ActionGroup5<A0, A1, A2, A3, A4>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context
    {
        ActionGroup5(a0, group(actions: a1, a2, a3, a4))
    }

    private static func group<A0, A1, A2, A3, A4, A5>(
        actions a0: A0, _ a1: A1, _ a2: A2, _ a3: A3, _ a4: A4, _ a5: A5
    ) -> ActionGroup6<A0, A1, A2, A3, A4, A5>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A5: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context,
        A0.Context == A5.Context
    {
        ActionGroup6(a0, group(actions: a1, a2, a3, a4, a5))
    }

    private static func ungroup<A0, A1>(
        _ group: ActionGroup<A0, A1>
    ) -> (A0, A1)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A0.Context == A1.Context
    {
        group.actions
    }

    private static func ungroup<A0, A1, A2>(
        _ group: ActionGroup3<A0, A1, A2>
    ) -> (A0, A1, A2)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context
    {
        Meta.foldr(group.actions.0, ungroup(group.actions.1))
    }

    private static func ungroup<A0, A1, A2, A3>(
        _ group: ActionGroup4<A0, A1, A2, A3>
    ) -> (A0, A1, A2, A3)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context
    {
        Meta.foldr(group.actions.0, ungroup(group.actions.1))
    }

    private static func ungroup<A0, A1, A2, A3, A4>(
        _ group: ActionGroup5<A0, A1, A2, A3, A4>
    ) -> (A0, A1, A2, A3, A4)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context
    {
        Meta.foldr(group.actions.0, ungroup(group.actions.1))
    }

    private static func ungroup<A0, A1, A2, A3, A4, A5>(
        _ group: ActionGroup6<A0, A1, A2, A3, A4, A5>
    ) -> (A0, A1, A2, A3, A4, A5)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A5: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context,
        A0.Context == A5.Context
    {
        Meta.foldr(group.actions.0, ungroup(group.actions.1))
    }
}
