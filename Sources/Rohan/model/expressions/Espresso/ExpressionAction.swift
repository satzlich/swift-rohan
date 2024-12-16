// Copyright 2024 Lie Yan

extension Espresso {
    /**
     An action that can be played on an expression
     */
    protocol ExpressionAction<Context> {
        associatedtype Context = Void

        mutating func onExpression(_ expression: Expression, _ context: Context)
    }
}
