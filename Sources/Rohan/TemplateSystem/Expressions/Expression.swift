// Copyright 2024-2025 Lie Yan

import Foundation

internal enum Expression: Equatable, Hashable {
    // Expression
    case apply(Apply)
    case variable(Variable)
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

    // MARK: - Access variants

    func variable() -> Variable? {
        switch self {
        case let .variable(variable):
            return variable
        default:
            return nil
        }
    }

    func namelessVariable() -> NamelessVariable? {
        switch self {
        case let .namelessVariable(namelessVariable):
            return namelessVariable
        default:
            return nil
        }
    }

    func content() -> Content? {
        switch self {
        case let .content(content):
            return content
        default:
            return nil
        }
    }

    func text() -> Text? {
        switch self {
        case let .text(text):
            return text
        default:
            return nil
        }
    }
}

extension Expression {
    var type: ExpressionType {
        switch self {
        case .apply:
            return .apply
        case .variable:
            return .variable
        case .namelessVariable:
            return .namelessVariable
        case .text:
            return .text
        case .content:
            return .content
        case .emphasis:
            return .emphasis
        case .heading:
            return .heading
        case .paragraph:
            return .paragraph
        case .equation:
            return .equation
        case .fraction:
            return .fraction
        case .matrix:
            return .matrix
        case .scripts:
            return .scripts
        }
    }
}

// MARK: - Expression

/**
 Template calls, for which `Apply` is a shorthand
 */
struct Apply: Equatable, Hashable {
    let templateName: TemplateName
    let arguments: [Content]

    init(_ templateName: TemplateName, arguments: [Content] = []) {
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

    func with(templateName: TemplateName) -> Apply {
        Apply(templateName, arguments: arguments)
    }

    func with(arguments: [Content]) -> Apply {
        Apply(templateName, arguments: arguments)
    }
}

/**
 Named variable
 */
struct Variable: Equatable, Hashable {
    let name: Identifier

    init(_ name: Identifier) {
        self.name = name
    }

    init(_ name: String) {
        self.init(Identifier(name))
    }

    func with(name: Identifier) -> Variable {
        Variable(name)
    }
}

/**
 Nameless variable
 */
struct NamelessVariable: Equatable, Hashable {
    let index: Int

    init(_ index: Int) {
        precondition(Self.validate(index: index))
        self.index = index
    }

    static func validate(index: Int) -> Bool {
        index >= 0
    }
}

// MARK: - Basics

public struct Root: Equatable, Hashable {
    // Empty
}

public struct Text: Equatable, Hashable {
    let string: String

    init(_ string: String) {
        self.string = string
    }

    static func + (lhs: Text, rhs: Text) -> Text {
        Text(lhs.string + rhs.string)
    }

    static func validate(string: String) -> Bool {
        // contains no new line character except new line separator
        !string.contains(where: { $0.isNewline && $0 != "\u{2028}" })
    }
}

struct Content: Equatable, Hashable {
    let expressions: [Expression]

    init(expressions: [Expression]) {
        self.expressions = expressions
    }

    init(@ContentBuilder content: () -> Content) {
        self = content()
    }

    func with(expressions: [Expression]) -> Content {
        Content(expressions: expressions)
    }

    var isEmpty: Bool {
        expressions.isEmpty
    }
}

public struct Emphasis: Equatable, Hashable {
    let content: Content

    init(content: Content) {
        self.content = content
    }

    init(@ContentBuilder content: () -> Content) {
        self.init(content: content())
    }

    func with(content: Content) -> Emphasis {
        Emphasis(content: content)
    }
}

public struct Heading: Equatable, Hashable {
    let level: Int
    let content: Content

    init(level: Int, content: Content) {
        self.level = level
        self.content = content
    }

    init(level: Int, @ContentBuilder content: () -> Content) {
        self.init(level: level, content: content())
    }

    func with(level: Int) -> Heading {
        Heading(level: level, content: content)
    }

    func with(content: Content) -> Heading {
        Heading(level: level, content: content)
    }

    public static func validate(level: Int) -> Bool {
        1 ... 5 ~= level
    }
}

public struct Paragraph: Equatable, Hashable {
    let content: Content

    init(content: Content) {
        self.content = content
    }

    init(@ContentBuilder content: () -> Content) {
        self.init(content: content())
    }

    func with(content: Content) -> Paragraph {
        Paragraph(content: content)
    }
}

// MARK: - Math

public struct Equation: Equatable, Hashable {
    let isBlock: Bool
    let content: Content

    init(isBlock: Bool, content: Content) {
        self.isBlock = isBlock
        self.content = content
    }

    init(isBlock: Bool, @ContentBuilder content: () -> Content) {
        self.init(isBlock: isBlock, content: content())
    }

    func with(isBlock: Bool) -> Equation {
        Equation(isBlock: isBlock, content: content)
    }

    func with(content: Content) -> Equation {
        Equation(isBlock: isBlock, content: content)
    }
}

struct Fraction: Equatable, Hashable {
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

    func with(numerator: Content) -> Fraction {
        Fraction(numerator: numerator, denominator: denominator)
    }

    func with(denominator: Content) -> Fraction {
        Fraction(numerator: numerator, denominator: denominator)
    }
}

struct Matrix: Equatable, Hashable {
    let rows: [MatrixRow]

    init(rows: [MatrixRow]) {
        precondition(Matrix.validate(rows: rows))
        self.rows = rows
    }

    init(@MatrixRowsBuilder rows: () -> [MatrixRow]) {
        self.init(rows: rows())
    }

    func with(rows: [MatrixRow]) -> Matrix {
        precondition(Matrix.validate(rows: rows))
        return Matrix(rows: rows)
    }

    static func validate(rows: [MatrixRow]) -> Bool {
        // non empty and has the size of the first row
        !rows.isEmpty &&
            !rows[0].isEmpty &&
            rows.dropFirst().allSatisfy { row in
                row.count == rows[0].count
            }
    }
}

struct MatrixRow: Equatable, Hashable {
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

    func with(elements: [Content]) -> MatrixRow {
        MatrixRow(elements: elements)
    }
}

struct Scripts: Equatable, Hashable {
    let subScript: Content?
    let superScript: Content?

    init(subScript: Content? = nil, superScript: Content? = nil) {
        precondition(subScript != nil || superScript != nil)
        self.subScript = subScript
        self.superScript = superScript
    }

    init(@ContentBuilder subScript: () -> Content) {
        self.init(subScript: subScript())
    }

    init(@ContentBuilder superScript: () -> Content) {
        self.init(superScript: superScript())
    }

    init(@ContentBuilder subScript: () -> Content,
         @ContentBuilder superScript: () -> Content)
    {
        self.init(subScript: subScript(), superScript: superScript())
    }

    func with(subScript: Content) -> Scripts {
        Scripts(subScript: subScript, superScript: superScript)
    }

    func with(superScript: Content) -> Scripts {
        Scripts(subScript: subScript, superScript: superScript)
    }
}
