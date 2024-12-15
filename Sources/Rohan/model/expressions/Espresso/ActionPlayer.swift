// Copyright 2024 Lie Yan

extension Espresso {
    /**
     Convenience function to simply play a plugin on a content
     */
    static func play<A>(action: A, on content: Content) -> A
        where A: ExpressionAction, A.Context == Void
    {
        let player = ActionPlayer(action)
        player.visit(content: content, ())
        return player.action
    }

    private final class ActionPlayer<A>: ExpressionVisitor<A.Context>
    where A: ExpressionAction {
        typealias Context = A.Context

        private(set) var action: A

        init(_ action: A) {
            self.action = action
        }

        override func visit(expression: Expression, _ context: Context) {
            action.visit(expression: expression, context)
            super.visit(expression: expression, context)
        }
    }
}
