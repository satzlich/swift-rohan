// Copyright 2024 Lie Yan

import Foundation

class ExpressionVisitor<C> {
    func visit(expression: Expression, _ context: C) {
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

    func visit(apply: Apply, _ context: C) {
        for argument in apply.arguments {
            visit(content: argument, context)
        }
    }

    func visit(variable: Variable, _ context: C) {
        // do nothing
    }

    func visit(namelessApply: NamelessApply, _ context: C) {
        for argument in namelessApply.arguments {
            visit(content: argument, context)
        }
    }

    func visit(namelessVariable: NamelessVariable, _ context: C) {
        // do nothing
    }

    func visit(text: Text, _ context: C) {
        // do nothing
    }

    func visit(content: Content, _ context: C) {
        for expression in content.expressions {
            visit(expression: expression, context)
        }
    }

    func visit(emphasis: Emphasis, _ context: C) {
        visit(content: emphasis.content, context)
    }

    func visit(heading: Heading, _ context: C) {
        visit(content: heading.content, context)
    }

    func visit(paragraph: Paragraph, _ context: C) {
        visit(content: paragraph.content, context)
    }

    func visit(equation: Equation, _ context: C) {
        visit(content: equation.content, context)
    }

    func visit(fraction: Fraction, _ context: C) {
        visit(content: fraction.numerator, context)
        visit(content: fraction.denominator, context)
    }

    func visit(matrix: Matrix, _ context: C) {
        for row in matrix.rows {
            for element in row.elements {
                visit(content: element, context)
            }
        }
    }

    func visit(scripts: Scripts, _ context: C) {
        if let `subscript` = scripts.subscript {
            visit(content: `subscript`, context)
        }
        if let superscript = scripts.superscript {
            visit(content: superscript, context)
        }
    }
}
