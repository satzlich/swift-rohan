// Copyright 2024 Lie Yan

/**
 Plugin for the `ExpressionVisitor`
 */
protocol ExpressionPlugin: AnyObject {
    typealias Context = Void

    func visitApply(_ apply: Apply, _ context: Context)
    func visitVariable(_ variable: Variable, _ context: Context)
    func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Context)
    func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Context)
    func visitText(_ text: Text, _ context: Context)
    func visitContent(_ content: Content, _ context: Context)
    func visitEmphasis(_ emphasis: Emphasis, _ context: Context)
    func visitHeading(_ heading: Heading, _ context: Context)
    func visitParagraph(_ paragraph: Paragraph, _ context: Context)
    func visitEquation(_ equation: Equation, _ context: Context)
    func visitFraction(_ fraction: Fraction, _ context: Context)
    func visitMatrix(_ matrix: Matrix, _ context: Context)
    func visitScripts(_ scripts: Scripts, _ context: Context)
}

extension ExpressionPlugin {
    func visitApply(_ apply: Apply, _ context: Context) { }
    func visitVariable(_ variable: Variable, _ context: Context) { }
    func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Context) { }
    func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Context) { }
    func visitText(_ text: Text, _ context: Context) { }
    func visitContent(_ content: Content, _ context: Context) { }
    func visitEmphasis(_ emphasis: Emphasis, _ context: Context) { }
    func visitHeading(_ heading: Heading, _ context: Context) { }
    func visitParagraph(_ paragraph: Paragraph, _ context: Context) { }
    func visitEquation(_ equation: Equation, _ context: Context) { }
    func visitFraction(_ fraction: Fraction, _ context: Context) { }
    func visitMatrix(_ matrix: Matrix, _ context: Context) { }
    func visitScripts(_ scripts: Scripts, _ context: Context) { }
}

final class ApplyCounter: ExpressionPlugin {
    private(set) var count = 0

    func visitApply(_ apply: Apply, _ context: Void) {
        count += 1
    }

    func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Void) {
        count += 1
    }
}

final class NamedVariableCounter: ExpressionPlugin {
    private(set) var count = 0

    func visitVariable(_ variable: Variable, _ context: Void) {
        count += 1
    }
}

final class NamelessVariable_OutOfRange_Counter: ExpressionPlugin {
    let parameterCount: Int

    private(set) var count = 0

    init(parameterCount: Int) {
        self.parameterCount = parameterCount
    }

    func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Void) {
        if namelessVariable.index >= parameterCount {
            count += 1
        }
    }
}
