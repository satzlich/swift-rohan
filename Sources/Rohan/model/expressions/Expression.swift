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
    @ContentsBuilder let arguments: [Content]

    init(_ templateName: Identifier) {
        self.init(templateName, arguments: [])
    }

    init(_ templateName: Identifier, arguments: [Content]) {
        self.templateName = templateName
        self.arguments = arguments
    }

    init(_ templateName: Identifier, @ContentsBuilder arguments: () -> [Content]) {
        self.init(templateName, arguments: arguments())
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
    let arguments: [Content]

    init(_ templateName: Int, arguments: [Content]) {
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

    init(expressions: [Expression]) {
        self.expressions = expressions
    }

    init(@ContentBuilder content: () -> Content) {
        self = content()
    }
}

struct Emphasis {
    @ContentBuilder let content: Content
}

struct Heading {
    let level: Int
    @ContentBuilder let content: Content
}

struct Paragraph {
    @ContentBuilder let content: Content
}

// MARK: - Math

struct Equation {
    let isBlock: Bool
    @ContentBuilder let content: Content
}

struct Fraction {
    @ContentBuilder let numerator: Content
    @ContentBuilder let denominator: Content
}

struct Matrix {
    @MatrixRowBuilder let rows: [MatrixRow]

    init?(rows: [MatrixRow]) {
        guard Matrix.validateRows(rows) else {
            return nil
        }
        self.rows = rows
    }

    init?(@MatrixRowBuilder rows: () -> [MatrixRow]) {
        self.init(rows: rows())
    }

    static func validateRows(_ rows: [MatrixRow]) -> Bool {
        // non empty and has the size of the first row
        !rows.isEmpty &&
            !rows.first!.isEmpty &&
            rows.allSatisfy { row in
                row.count == rows.first!.count
            }
    }
}

struct MatrixRow {
    @ContentsBuilder let elements: [Content]

    var isEmpty: Bool {
        elements.isEmpty
    }

    var count: Int {
        elements.count
    }
}

struct Scripts {
    @ContentBuilder let `subscript`: Content?
    @ContentBuilder let superscript: Content?

    init(subscript: Content) {
        self.subscript = `subscript`
        self.superscript = nil
    }

    init(@ContentBuilder subscript: () -> Content) {
        self.init(subscript: `subscript`())
    }

    init(superscript: Content) {
        self.superscript = superscript
        self.subscript = nil
    }

    init(@ContentBuilder superscript: () -> Content) {
        self.init(superscript: superscript())
    }

    init(subscript: Content, superscript: Content) {
        self.subscript = `subscript`
        self.superscript = superscript
    }

    init(@ContentBuilder subscript: () -> Content,
         @ContentBuilder superscript: () -> Content)
    {
        self.init(subscript: `subscript`(), superscript: superscript())
    }
}
