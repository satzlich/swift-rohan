// Copyright 2024 Lie Yan

class ExpressionRewriter<C> {
    typealias R = Expression

    func visitExpression(_ expression: Expression, _ context: C) -> R {
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

    func visitApply(_ apply: Apply, _ context: C) -> R {
        let res = apply
            .with(arguments: apply.arguments.map {
                visitContent($0, context).unwrapContent()!
            })
        return .apply(res)
    }

    func visitVariable(_ variable: Variable, _ context: C) -> R {
        .variable(variable)
    }

    func visitNamelessApply(_ namelessApply: NamelessApply, _ context: C) -> R {
        let res = namelessApply
            .with(arguments: namelessApply.arguments.map {
                visitContent($0, context).unwrapContent()!
            })
        return .namelessApply(res)
    }

    func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: C) -> R {
        .namelessVariable(namelessVariable)
    }

    func visitText(_ text: Text, _ context: C) -> R {
        .text(text)
    }

    func visitContent(_ content: Content, _ context: C) -> R {
        let res = content
            .with(expressions: content.expressions.map {
                visitExpression($0, context)
            })
        return .content(res)
    }

    func visitEmphasis(_ emphasis: Emphasis, _ context: C) -> R {
        let res = emphasis
            .with(content: visitContent(emphasis.content, context).unwrapContent()!)
        return .emphasis(res)
    }

    func visitHeading(_ heading: Heading, _ context: C) -> R {
        let res = heading
            .with(content: visitContent(heading.content, context).unwrapContent()!)
        return .heading(res)
    }

    func visitParagraph(_ paragraph: Paragraph, _ context: C) -> R {
        let res = paragraph
            .with(content: visitContent(paragraph.content, context).unwrapContent()!)
        return .paragraph(res)
    }

    func visitEquation(_ equation: Equation, _ context: C) -> R {
        let res = equation
            .with(content: visitContent(equation.content, context).unwrapContent()!)
        return .equation(res)
    }

    func visitFraction(_ fraction: Fraction, _ context: C) -> R {
        let res = fraction
            .with(numerator: visitContent(fraction.numerator, context).unwrapContent()!)
            .with(denominator: visitContent(fraction.denominator, context).unwrapContent()!)
        return .fraction(res)
    }

    func visitMatrix(_ matrix: Matrix, _ context: C) -> R {
        let res = matrix
            .with(rows:
                matrix.rows.map { row in
                    row.with(elements:
                        row.elements.map { element in
                            visitContent(element, context).unwrapContent()!
                        })
                })
        return .matrix(res)
    }

    func visitScripts(_ scripts: Scripts, _ context: C) -> R {
        var res = scripts
        if let `subscript` = scripts.subscript {
            res = res.with(subscript: visitContent(`subscript`, context).unwrapContent()!)
        }
        if let superscript = scripts.superscript {
            res = res.with(superscript: visitContent(superscript, context).unwrapContent()!)
        }
        return .scripts(res)
    }
}
