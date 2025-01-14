// Copyright 2024 Lie Yan

class ExpressionRewriter<C>: ExpressionVisitor<C, Expression> {
    typealias R = Expression

    override func visit(apply: Apply, _ context: C) -> R {
        let res = apply
            .with(arguments: apply.arguments.map {
                visit(content: $0, context).content()!
            })
        return .apply(res)
    }

    override func visit(variable: Variable, _ context: C) -> R {
        .variable(variable)
    }

    override func visit(namelessVariable: NamelessVariable, _ context: C) -> R {
        .namelessVariable(namelessVariable)
    }

    override func visit(text: Text, _ context: C) -> R {
        .text(text)
    }

    override func visit(content: Content, _ context: C) -> R {
        let res = content
            .with(expressions: content.expressions.map {
                visit(expression: $0, context)
            })
        return .content(res)
    }

    override func visit(emphasis: Emphasis, _ context: C) -> R {
        let res = emphasis
            .with(content: visit(content: emphasis.content, context).content()!)
        return .emphasis(res)
    }

    override func visit(heading: Heading, _ context: C) -> R {
        let res = heading
            .with(content: visit(content: heading.content, context).content()!)
        return .heading(res)
    }

    override func visit(paragraph: Paragraph, _ context: C) -> R {
        let res = paragraph
            .with(content: visit(content: paragraph.content, context).content()!)
        return .paragraph(res)
    }

    override func visit(equation: Equation, _ context: C) -> R {
        let res = equation
            .with(content: visit(content: equation.content, context).content()!)
        return .equation(res)
    }

    override func visit(fraction: Fraction, _ context: C) -> R {
        let res = fraction
            .with(numerator: visit(content: fraction.numerator, context).content()!)
            .with(denominator: visit(content: fraction.denominator, context).content()!)
        return .fraction(res)
    }

    override func visit(matrix: Matrix, _ context: C) -> R {
        let res = matrix
            .with(rows:
                matrix.rows.map { row in
                    row.with(elements:
                        row.elements.map { element in
                            visit(content: element, context).content()!
                        })
                })
        return .matrix(res)
    }

    override func visit(scripts: Scripts, _ context: C) -> R {
        var res = scripts
        if let subScript = scripts.subScript {
            res = res.with(subScript: visit(content: subScript, context).content()!)
        }
        if let superScript = scripts.superScript {
            res = res.with(superScript: visit(content: superScript, context).content()!)
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
        visit(content: content, context).content()!
    }
}
