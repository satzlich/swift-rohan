// Copyright 2024 Lie Yan

extension Espresso {
    /**
     Plugin for the `SimpleExpressionVisitor`
     */
    protocol ExpressionAction<Context> {
        associatedtype Context = Void

        mutating func onExpression(_ expression: Expression, _ context: Context)
    }
}
