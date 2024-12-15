// Copyright 2024 Lie Yan

extension Espresso {
    /**
     Plugin for the `ExpressionVisitor`
     */
    protocol VisitorPlugin<Context> {
        associatedtype Context = Void

        mutating func visit(expression: Expression, _ context: Context)
    }
}
