// Copyright 2024 Lie Yan

import Foundation

indirect enum Expression {
    // Expression
    case apply(Apply)
    case variable(Variable)

    // Basics
    case text(Text)
    case content(Content)
    case emphasis(Emphasis)
    case heading(Heading)
    case paragraph(Paragraph)

    // Math
    case equation(Equation)
    case fraction(Fraction)
    case matrix(Matrix)
    case scripts(Scripts)

    // MARK: - Expression

    struct Apply {
        let templateName: Identifier
        let arguments: [Expression]
    }

    struct Variable {
        let name: Identifier
    }

    // MARK: - Basics

    struct Text {
        let string: String
    }

    struct Content {
        let expressions: [Expression]
    }

    struct Emphasis {
        let expressions: [Expression]
    }

    struct Heading {
        let level: Int
        let expressions: [Expression]
    }

    struct Paragraph {
        let expressions: [Expression]
    }

    // MARK: - Math

    struct Equation {
        let isBlock: Bool
        let expressions: [Expression]
    }

    struct Fraction {
        let numerator: Expression
        let denominator: Expression
    }

    struct Matrix {
        struct Row {
            let elements: [Expression]
        }

        let rows: [Row]
    }

    struct Scripts {
        let `subscript`: Expression?
        let superscript: Expression?
    }
}
