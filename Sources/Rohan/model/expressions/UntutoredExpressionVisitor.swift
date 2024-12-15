// Copyright 2024 Lie Yan

import Foundation

/**
 A visitor where everything must be overridden, and nothing will be forgotten
 */
class UntutoredExpressionVisitor<C> {
    func visitExpression(_ expression: Expression, _ context: C) {
        switch expression {
        case let .apply(apply):
            visitApply(apply, context)
        case let .variable(variable):
            visitVariable(variable, context)
        case let .namelessApply(namelessApply):
            visitNamelessApply(namelessApply, context)
        case let .namelessVariable(namelessVariable):
            visitNamelessVariable(namelessVariable, context)
        case let .text(text):
            visitText(text, context)
        case let .content(content):
            visitContent(content, context)
        case let .emphasis(emphasis):
            visitEmphasis(emphasis, context)
        case let .heading(heading):
            visitHeading(heading, context)
        case let .paragraph(paragraph):
            visitParagraph(paragraph, context)
        case let .equation(equation):
            visitEquation(equation, context)
        case let .fraction(fraction):
            visitFraction(fraction, context)
        case let .matrix(matrix):
            visitMatrix(matrix, context)
        case let .scripts(scripts):
            visitScripts(scripts, context)
        }
    }

    func visitApply(_ apply: Apply, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitVariable(_ variable: Variable, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitNamelessApply(_ namelessApply: NamelessApply, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitText(_ text: Text, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitContent(_ content: Content, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitEmphasis(_ emphasis: Emphasis, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitHeading(_ heading: Heading, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitParagraph(_ paragraph: Paragraph, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitEquation(_ equation: Equation, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitFraction(_ fraction: Fraction, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitMatrix(_ matrix: Matrix, _ context: C) {
        preconditionFailure("Must be overridden")
    }

    func visitScripts(_ scripts: Scripts, _ context: C) {
        preconditionFailure("Must be overridden")
    }
}
