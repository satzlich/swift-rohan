// Copyright 2024 Lie Yan

/**
 Plugin for the `ExpressionVisitor`
 */
protocol ExpressionPlugin {
    typealias Context = Void

    mutating func visitApply(_ apply: Apply, _ context: Context)
    mutating func visitVariable(_ variable: Variable, _ context: Context)
    mutating func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Context)
    mutating func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Context)
    mutating func visitText(_ text: Text, _ context: Context)
    mutating func visitContent(_ content: Content, _ context: Context)
    mutating func visitEmphasis(_ emphasis: Emphasis, _ context: Context)
    mutating func visitHeading(_ heading: Heading, _ context: Context)
    mutating func visitParagraph(_ paragraph: Paragraph, _ context: Context)
    mutating func visitEquation(_ equation: Equation, _ context: Context)
    mutating func visitFraction(_ fraction: Fraction, _ context: Context)
    mutating func visitMatrix(_ matrix: Matrix, _ context: Context)
    mutating func visitScripts(_ scripts: Scripts, _ context: Context)
}

extension ExpressionPlugin {
    mutating func visitApply(_ apply: Apply, _ context: Context) { }
    mutating func visitVariable(_ variable: Variable, _ context: Context) { }
    mutating func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Context) { }
    mutating func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Context) { }
    mutating func visitText(_ text: Text, _ context: Context) { }
    mutating func visitContent(_ content: Content, _ context: Context) { }
    mutating func visitEmphasis(_ emphasis: Emphasis, _ context: Context) { }
    mutating func visitHeading(_ heading: Heading, _ context: Context) { }
    mutating func visitParagraph(_ paragraph: Paragraph, _ context: Context) { }
    mutating func visitEquation(_ equation: Equation, _ context: Context) { }
    mutating func visitFraction(_ fraction: Fraction, _ context: Context) { }
    mutating func visitMatrix(_ matrix: Matrix, _ context: Context) { }
    mutating func visitScripts(_ scripts: Scripts, _ context: Context) { }
}

struct NamedApplyCounter: ExpressionPlugin {
    private(set) var count = 0

    mutating func visitApply(_ apply: Apply, _ context: Void) {
        count += 1
    }
}

struct NamelessApplyCounter: ExpressionPlugin {
    private(set) var count = 0

    mutating func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Void) {
        count += 1
    }
}

struct NamedVariableCounter: ExpressionPlugin {
    private(set) var count = 0

    mutating func visitVariable(_ variable: Variable, _ context: Void) {
        count += 1
    }
}

struct NamelessVariableCounter: ExpressionPlugin {
    private(set) var count = 0

    mutating func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Void) {
        count += 1
    }
}
