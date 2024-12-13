// Copyright 2024 Lie Yan

import Foundation

class ExpressionVisitor<C> {
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
        for argument in apply.arguments {
            visitContent(argument, context)
        }
    }

    func visitVariable(_ variable: Variable, _ context: C) {
        // do nothing
    }

    func visitNamelessApply(_ namelessApply: NamelessApply, _ context: C) {
        for argument in namelessApply.arguments {
            visitContent(argument, context)
        }
    }

    func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: C) {
        // do nothing
    }

    func visitText(_ text: Text, _ context: C) {
        // do nothing
    }

    func visitContent(_ content: Content, _ context: C) {
        for expression in content.expressions {
            visitExpression(expression, context)
        }
    }

    func visitEmphasis(_ emphasis: Emphasis, _ context: C) {
        visitContent(emphasis.content, context)
    }

    func visitHeading(_ heading: Heading, _ context: C) {
        visitContent(heading.content, context)
    }

    func visitParagraph(_ paragraph: Paragraph, _ context: C) {
        visitContent(paragraph.content, context)
    }

    func visitEquation(_ equation: Equation, _ context: C) {
        visitContent(equation.content, context)
    }

    func visitFraction(_ fraction: Fraction, _ context: C) {
        visitContent(fraction.numerator, context)
        visitContent(fraction.denominator, context)
    }

    func visitMatrix(_ matrix: Matrix, _ context: C) {
        for row in matrix.rows {
            for element in row.elements {
                visitContent(element, context)
            }
        }
    }

    func visitScripts(_ scripts: Scripts, _ context: C) {
        if let `subscript` = scripts.subscript {
            visitContent(`subscript`, context)
        }
        if let superscript = scripts.superscript {
            visitContent(superscript, context)
        }
    }
}
