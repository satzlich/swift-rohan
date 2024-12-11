// Copyright 2024 Lie Yan

import Foundation

@resultBuilder
struct ExpressionBuilder {
    static func buildBlock(_ components: [Expression] ...) -> [Expression] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: Expression) -> [Expression] {
        [expression]
    }

    static func buildExpression(_ string: String) -> [Expression] {
        [.text(.init(string))]
    }

    static func buildExpression(_ emphasis: Emphasis) -> [Expression] {
        [.emphasis(emphasis)]
    }

    static func buildExpression(_ heading: Heading) -> [Expression] {
        [.heading(heading)]
    }

    static func buildExpression(_ paragraph: Paragraph) -> [Expression] {
        [.paragraph(paragraph)]
    }

    static func buildExpression(_ equation: Equation) -> [Expression] {
        [.equation(equation)]
    }

    static func buildExpression(_ fraction: Fraction) -> [Expression] {
        [.fraction(fraction)]
    }
}

func makeExpressions(@ExpressionBuilder makeContent: () -> [Expression]) -> [Expression] {
    makeContent()
}

// MARK: - makeApply

func makeApply(templateName: Identifier) -> Apply {
    Apply(templateName, arguments: [])
}

func makeApply(templateName: Identifier,
               @ExpressionBuilder arguments a0: () -> [Expression]) -> Apply
{
    Apply(templateName, arguments: [a0()])
}

func makeApply(templateName: Identifier,
               @ExpressionBuilder arguments a0: () -> [Expression],
               @ExpressionBuilder _ a1: () -> [Expression]) -> Apply
{
    Apply(templateName, arguments: [a0(), a1()])
}

func makeApply(templateName: Identifier,
               @ExpressionBuilder arguments a0: () -> [Expression],
               @ExpressionBuilder _ a1: () -> [Expression],
               @ExpressionBuilder _ a2: () -> [Expression]) -> Apply
{
    Apply(templateName, arguments: [a0(), a1(), a2()])
}

// MARK: - Other

func makeContent(@ExpressionBuilder makeContent: () -> [Expression]) -> Content {
    Content(expressions: makeContent())
}

func makeEmphasis(@ExpressionBuilder makeContent: () -> [Expression]) -> Emphasis {
    Emphasis(expressions: makeContent())
}

func makeHeading(level: Int,
                 @ExpressionBuilder makeContent: () -> [Expression]) -> Heading
{
    Heading(level: level, expressions: makeContent())
}

func makeParagraph(@ExpressionBuilder makeContent: () -> [Expression]) -> Paragraph {
    Paragraph(expressions: makeContent())
}

func makeEquation(isBlock: Bool,
                  @ExpressionBuilder makeContent: () -> [Expression]) -> Equation
{
    Equation(isBlock: isBlock, expressions: makeContent())
}

func makeFraction(@ExpressionBuilder numerator: () -> [Expression],
                  @ExpressionBuilder denominator: () -> [Expression]) -> Fraction
{
    Fraction(numerator: numerator(), denominator: denominator())
}
