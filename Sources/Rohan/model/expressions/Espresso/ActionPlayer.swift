// Copyright 2024 Lie Yan

extension Espresso {
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
        _ = play(action: HandyAction(closure: closure), on: content)
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

    static func counter(predicate: @escaping (Expression) -> Bool) -> PredicatedCounter<Void> {
        PredicatedCounter { expression, _ in predicate(expression) }
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
