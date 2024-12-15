// Copyright 2024 Lie Yan

import Foundation

extension Espresso {
    struct ActionGroup<A, B>: ExpressionAction
        where A: ExpressionAction,
        B: ExpressionAction,
        A.Context == B.Context
    {
        typealias Context = A.Context

        private(set) var actions: (A, B)

        init(_ a: A, _ b: B) {
            self.actions = (a, b)
        }

        mutating func visit(expression: Expression, _ context: Context) {
            actions.0.visit(expression: expression, context)
            actions.1.visit(expression: expression, context)
        }
    }

    typealias ActionGroup2<A0, A1> = ActionGroup<A0, A1>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A0.Context == A1.Context

    typealias ActionGroup3<A0, A1, A2> = ActionGroup<A0, ActionGroup2<A1, A2>>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context

    typealias ActionGroup4<A0, A1, A2, A3> = ActionGroup<A0, ActionGroup3<A1, A2, A3>>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context

    typealias ActionGroup5<A0, A1, A2, A3, A4> = ActionGroup<A0, ActionGroup4<A1, A2, A3, A4>>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A2: ExpressionAction,
        A3: ExpressionAction,
        A4: ExpressionAction,
        A0.Context == A1.Context,
        A0.Context == A2.Context,
        A0.Context == A3.Context,
        A0.Context == A4.Context

    typealias ActionGroup6<A0, A1, A2, A3, A4, A5> = ActionGroup<A0, ActionGroup5<A1, A2, A3, A4, A5>>
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

    static func group<A0, A1>(
        actions a0: A0, _ a1: A1
    ) -> ActionGroup2<A0, A1>
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A0.Context == A1.Context
    {
        ActionGroup(a0, a1)
    }

    static func group<A0, A1, A2>(
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

    static func group<A0, A1, A2, A3>(
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

    static func group<A0, A1, A2, A3, A4>(
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

    static func group<A0, A1, A2, A3, A4, A5>(
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

    static func ungroup<A0, A1>(
        _ group: ActionGroup<A0, A1>
    ) -> (A0, A1)
        where A0: ExpressionAction,
        A1: ExpressionAction,
        A0.Context == A1.Context
    {
        group.actions
    }

    static func ungroup<A0, A1, A2>(
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

    static func ungroup<A0, A1, A2, A3>(
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

    static func ungroup<A0, A1, A2, A3, A4>(
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

    static func ungroup<A0, A1, A2, A3, A4, A5>(
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
