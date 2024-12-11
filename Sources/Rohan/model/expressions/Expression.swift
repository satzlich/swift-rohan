// Copyright 2024 Lie Yan

import Foundation

indirect enum Expression {
    // Expression
    case apply(Apply)
    case variable(Variable)

    // Nameless
    case namelessApply(NamelessApply)
    case namelessVariable(NamelessVariable)

    // Basics
    case content(Content)
    case text(Text)
    case emphasis(Emphasis)
    case heading(Heading)
    case paragraph(Paragraph)

    // Math
    case equation(Equation)
    case fraction(Fraction)
    case matrix(Matrix)
    case scripts(Scripts)
}

// MARK: - Expression

struct Apply {
    let templateName: Identifier
    let arguments: [[Expression]]

    init(_ templateName: Identifier, arguments: [[Expression]]) {
        self.templateName = templateName
        self.arguments = arguments
    }
}

struct Variable {
    let name: Identifier

    init(_ name: Identifier) {
        self.name = name
    }
}

struct NamelessApply {
    let templateIndex: Int
    let arguments: [Expression]

    init(_ templateName: Int, arguments: [Expression]) {
        precondition(templateName >= 0)
        self.templateIndex = templateName
        self.arguments = arguments
    }
}

struct NamelessVariable {
    let index: Int

    init(_ index: Int) {
        precondition(index >= 0)
        self.index = index
    }
}

// MARK: - Basics

struct Text {
    let string: String

    init(_ string: String) {
        self.string = string
    }
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
    let numerator: [Expression]
    let denominator: [Expression]
}

struct Matrix {
    struct Row {
        let elements: [Expression]
    }

    let rows: [Row]
}

struct Scripts {
    let `subscript`: [Expression]?
    let superscript: [Expression]?
}
