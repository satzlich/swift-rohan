// Copyright 2024 Lie Yan

/**
 Context-free visitor
 */
class SimpleExpressionVisitor: ExpressionVisitor<Void> {
    func invoke(with content: Content) -> Self {
        visitContent(content, ())
        return self
    }

    func invoke(with expression: Expression) -> Self {
        expression.accept(self, ())
        return self
    }
}

