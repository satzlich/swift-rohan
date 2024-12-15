// Copyright 2024 Lie Yan

class ExpressionRewriter<C> {
    typealias R = Expression

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
        let res = apply
            .with(arguments: apply.arguments.map {
                visit(content: $0, context).unwrapContent()!
            })
        return .apply(res)
    }

    func visit(variable: Variable, _ context: C) -> R {
        .variable(variable)
    }

    func visit(namelessApply: NamelessApply, _ context: C) -> R {
        let res = namelessApply
            .with(arguments: namelessApply.arguments.map {
                visit(content: $0, context).unwrapContent()!
            })
        return .namelessApply(res)
    }

    func visit(namelessVariable: NamelessVariable, _ context: C) -> R {
        .namelessVariable(namelessVariable)
    }

    func visit(text: Text, _ context: C) -> R {
        .text(text)
    }

    func visit(content: Content, _ context: C) -> R {
        let res = content
            .with(expressions: content.expressions.map {
                visit(expression: $0, context)
            })
        return .content(res)
    }

    func visit(emphasis: Emphasis, _ context: C) -> R {
        let res = emphasis
            .with(content: visit(content: emphasis.content, context).unwrapContent()!)
        return .emphasis(res)
    }

    func visit(heading: Heading, _ context: C) -> R {
        let res = heading
            .with(content: visit(content: heading.content, context).unwrapContent()!)
        return .heading(res)
    }

    func visit(paragraph: Paragraph, _ context: C) -> R {
        let res = paragraph
            .with(content: visit(content: paragraph.content, context).unwrapContent()!)
        return .paragraph(res)
    }

    func visit(equation: Equation, _ context: C) -> R {
        let res = equation
            .with(content: visit(content: equation.content, context).unwrapContent()!)
        return .equation(res)
    }

    func visit(fraction: Fraction, _ context: C) -> R {
        let res = fraction
            .with(numerator: visit(content: fraction.numerator, context).unwrapContent()!)
            .with(denominator: visit(content: fraction.denominator, context).unwrapContent()!)
        return .fraction(res)
    }

    func visit(matrix: Matrix, _ context: C) -> R {
        let res = matrix
            .with(rows:
                matrix.rows.map { row in
                    row.with(elements:
                        row.elements.map { element in
                            visit(content: element, context).unwrapContent()!
                        })
                })
        return .matrix(res)
    }

    func visit(scripts: Scripts, _ context: C) -> R {
        var res = scripts
        if let `subscript` = scripts.subscript {
            res = res.with(subscript: visit(content: `subscript`, context).unwrapContent()!)
        }
        if let superscript = scripts.superscript {
            res = res.with(superscript: visit(content: superscript, context).unwrapContent()!)
        }
        return .scripts(res)
    }

    /**
     Convenience method to rewrite an expression.
     */
    func rewrite(expression: Expression, _ context: C) -> R {
        visit(expression: expression, context)
    }

    func rewrite(content: Content, _ context: C) -> Content {
        visit(content: content, context).unwrapContent()!
    }
}
