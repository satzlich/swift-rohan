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
    case content(Content)
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

/**
 Named apply
 */
struct Apply {
    let templateName: TemplateName
    let arguments: [Content]

    init(_ templateName: TemplateName) {
        self.init(templateName, arguments: [])
    }

    init(_ templateName: TemplateName, arguments: [Content]) {
        self.templateName = templateName
        self.arguments = arguments
    }

    init(_ templateName: TemplateName,
         @ContentBuilder _ a0: () -> Content)
    {
        self.init(templateName, arguments: [a0()])
    }

    init(_ templateName: TemplateName,
         @ContentBuilder _ a0: () -> Content,
         @ContentBuilder _ a1: () -> Content)
    {
        self.init(templateName, arguments: [a0(), a1()])
    }

    init(_ templateName: TemplateName,
         @ContentBuilder _ a0: () -> Content,
         @ContentBuilder _ a1: () -> Content,
         @ContentBuilder _ a2: () -> Content)
    {
        self.init(templateName, arguments: [a0(), a1(), a2()])
    }

    init(_ templateName: TemplateName,
         @ContentBuilder _ a0: () -> Content,
         @ContentBuilder _ a1: () -> Content,
         @ContentBuilder _ a2: () -> Content,
         @ContentBuilder _ a3: () -> Content)
    {
        self.init(templateName, arguments: [a0(), a1(), a2(), a3()])
    }

    init(_ templateName: TemplateName,
         @ContentBuilder _ a0: () -> Content,
         @ContentBuilder _ a1: () -> Content,
         @ContentBuilder _ a2: () -> Content,
         @ContentBuilder _ a3: () -> Content,
         @ContentBuilder _ a4: () -> Content)
    {
        self.init(templateName, arguments: [a0(), a1(), a2(), a3(), a4()])
    }

    init(_ templateName: TemplateName,
         @ContentBuilder _ a0: () -> Content,
         @ContentBuilder _ a1: () -> Content,
         @ContentBuilder _ a2: () -> Content,
         @ContentBuilder _ a3: () -> Content,
         @ContentBuilder _ a4: () -> Content,
         @ContentBuilder _ a5: () -> Content)
    {
        self.init(templateName, arguments: [a0(), a1(), a2(), a3(), a4(), a5()])
    }
}

/**
 Named variable
 */
struct Variable {
    let name: Identifier

    init(_ name: Identifier) {
        self.name = name
    }

    init?(_ name: String) {
        guard let identifier = Identifier(name) else {
            return nil
        }
        self.init(identifier)
    }
}

struct NamelessApply {
    let templateIndex: Int
    let arguments: [Content]

    init(_ templateIndex: Int, arguments: [Content]) {
        precondition(templateIndex >= 0)
        self.templateIndex = templateIndex
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
    let content: Content

    init(content: Content) {
        self.content = content
    }

    init(@ContentBuilder content: () -> Content) {
        self.init(content: content())
    }
}

struct Heading {
    let level: Int
    let content: Content

    init(level: Int, content: Content) {
        self.level = level
        self.content = content
    }

    init(level: Int, @ContentBuilder content: () -> Content) {
        self.init(level: level, content: content())
    }
}

struct Paragraph {
    let content: Content

    init(content: Content) {
        self.content = content
    }

    init(@ContentBuilder content: () -> Content) {
        self.init(content: content())
    }
}

// MARK: - Math

struct Equation {
    let isBlock: Bool
    let content: Content

    init(isBlock: Bool, content: Content) {
        self.isBlock = isBlock
        self.content = content
    }

    init(isBlock: Bool, @ContentBuilder content: () -> Content) {
        self.init(isBlock: isBlock, content: content())
    }
}

struct Fraction {
    let numerator: Content
    let denominator: Content

    init(numerator: Content, denominator: Content) {
        self.numerator = numerator
        self.denominator = denominator
    }

    init(@ContentBuilder numerator: () -> Content,
         @ContentBuilder denominator: () -> Content)
    {
        self.init(numerator: numerator(), denominator: denominator())
    }
}

struct Matrix {
    let rows: [MatrixRow]

    init?(rows: [MatrixRow]) {
        guard Matrix.validateRows(rows) else {
            return nil
        }
        self.rows = rows
    }

    init?(@MatrixRowsBuilder rows: () -> [MatrixRow]) {
        self.init(rows: rows())
    }

    static func validateRows(_ rows: [MatrixRow]) -> Bool {
        // non empty and has the size of the first row
        !rows.isEmpty &&
            !rows[0].isEmpty &&
            rows.dropFirst().allSatisfy { row in
                row.count == rows[0].count
            }
    }
}

struct MatrixRow {
    let elements: [Content]

    init(elements: [Content]) {
        self.elements = elements
    }

    init(@ContentsBuilder elements: () -> [Content]) {
        self.init(elements: elements())
    }

    var isEmpty: Bool {
        elements.isEmpty
    }

    var count: Int {
        elements.count
    }
}

struct Scripts {
    let `subscript`: Content?
    let superscript: Content?

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
