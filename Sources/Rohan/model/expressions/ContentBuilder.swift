// Copyright 2024 Lie Yan

import Foundation

@resultBuilder
struct ContentBuilder {
    static func buildFinalResult(_ expressions: [Expression]) -> Content {
        Content(expressions: expressions)
    }

    // MARK: - COPY HERE FROM `ExpressionsBuilder`

    static func buildBlock(_ components: [Expression] ...) -> [Expression] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: Expression) -> [Expression] {
        [expression]
    }

    static func buildExpression(_ string: String) -> [Expression] {
        [.text(.init(string))]
    }

    static func buildExpression(_ text: Text) -> [Expression] {
        [.text(text)]
    }

    static func buildExpression(_ apply: Apply) -> [Expression] {
        [.apply(apply)]
    }

    static func buildExpression(_ variable: Variable) -> [Expression] {
        [.variable(variable)]
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

    static func buildExpression(_ matrix: Matrix) -> [Expression] {
        [.matrix(matrix)]
    }

    static func buildExpression(_ scripts: Scripts) -> [Expression] {
        [.scripts(scripts)]
    }
}

@resultBuilder
struct ContentsBuilder {
    static func buildBlock(_ components: [Content]...) -> [Content] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: Content) -> [Content] {
        [expression]
    }
}

@resultBuilder
struct MatrixRowBuilder {
    static func buildBlock(_ components: [MatrixRow]...) -> [MatrixRow] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: MatrixRow) -> [MatrixRow] {
        [expression]
    }
}
