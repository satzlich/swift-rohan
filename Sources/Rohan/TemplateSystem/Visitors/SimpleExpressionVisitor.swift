// Copyright 2024 Lie Yan

import Foundation

class SimpleExpressionVisitor<C>: ExpressionVisitor<C, Void> {
    override func visit(apply: Apply, _ context: C) {
        for argument in apply.arguments {
            visit(content: argument, context)
        }
    }

    override func visit(variable: Variable, _ context: C) {
        // do nothing
    }

    override func visit(namelessVariable: NamelessVariable, _ context: C) {
        // do nothing
    }

    override func visit(text: Text, _ context: C) {
        // do nothing
    }

    override func visit(content: Content, _ context: C) {
        for expression in content.expressions {
            visit(expression: expression, context)
        }
    }

    override func visit(emphasis: Emphasis, _ context: C) {
        visit(content: emphasis.content, context)
    }

    override func visit(heading: Heading, _ context: C) {
        visit(content: heading.content, context)
    }

    override func visit(paragraph: Paragraph, _ context: C) {
        visit(content: paragraph.content, context)
    }

    override func visit(equation: Equation, _ context: C) {
        visit(content: equation.content, context)
    }

    override func visit(fraction: Fraction, _ context: C) {
        visit(content: fraction.numerator, context)
        visit(content: fraction.denominator, context)
    }

    override func visit(matrix: Matrix, _ context: C) {
        for row in matrix.rows {
            for element in row.elements {
                visit(content: element, context)
            }
        }
    }

    override func visit(scripts: Scripts, _ context: C) {
        if let subScript = scripts.subScript {
            visit(content: subScript, context)
        }
        if let superScript = scripts.superScript {
            visit(content: superScript, context)
        }
    }
}
