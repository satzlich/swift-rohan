// Copyright 2024 Lie Yan

extension Espresso {
    /**
     Plugin for the `ExpressionVisitor`
     */
    protocol VisitorPlugin {
        typealias Context = Void

        mutating func visitExpression(_ expression: Expression, _ context: Context)
    }
}
