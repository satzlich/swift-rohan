// Copyright 2024 Lie Yan

import Foundation

/**
 A visitor where everything must be overridden, and nothing will be forgotten
 */
class ExpressionVisitor<C, R> {
    func visit(expression: Expression, _ context: C) -> R {
        switch expression {
        case let .apply(apply):
            visit(apply: apply, context)
        case let .variable(variable):
            visit(variable: variable, context)
        case let .namelessApply(namelessApply):
            visit(namelessApply: namelessApply, context)
        case let .namelessVariable(namelessVariable):
            visit(namelessVariable: namelessVariable, context)
        case let .text(text):
            visit(text: text, context)
        case let .content(content):
            visit(content: content, context)
        case let .emphasis(emphasis):
            visit(emphasis: emphasis, context)
        case let .heading(heading):
            visit(heading: heading, context)
        case let .paragraph(paragraph):
            visit(paragraph: paragraph, context)
        case let .equation(equation):
            visit(equation: equation, context)
        case let .fraction(fraction):
            visit(fraction: fraction, context)
        case let .matrix(matrix):
            visit(matrix: matrix, context)
        case let .scripts(scripts):
            visit(scripts: scripts, context)
        }
    }

    func visit(apply: Apply, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(variable: Variable, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(namelessApply: NamelessApply, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(namelessVariable: NamelessVariable, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(text: Text, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(content: Content, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(emphasis: Emphasis, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(heading: Heading, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(paragraph: Paragraph, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(equation: Equation, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(fraction: Fraction, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(matrix: Matrix, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }

    func visit(scripts: Scripts, _ context: C) -> R {
        preconditionFailure("Must be overridden")
    }
}
