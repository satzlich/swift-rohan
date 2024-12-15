// Copyright 2024 Lie Yan

extension Espresso {
    /**
     Plugin for the `ExpressionVisitor`
     */
    protocol ExpressionAction<Context> {
        associatedtype Context = Void

        mutating func visit(expression: Expression, _ context: Context)
    }
}
