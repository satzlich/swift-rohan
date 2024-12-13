// Copyright 2024 Lie Yan

final class ExpressionPluginPlayer<P>: ExpressionVisitor<Void> where P: ExpressionPlugin {
    typealias Context = P.Context

    private(set) var plugin: P

    init(_ plugin: P) {
        self.plugin = plugin
    }

    override func visitApply(_ apply: Apply, _ context: Context) {
        plugin.visitApply(apply, context)
        super.visitApply(apply, context)
    }

    override func visitVariable(_ variable: Variable, _ context: Context) {
        plugin.visitVariable(variable, context)
        super.visitVariable(variable, context)
    }

    override func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Context) {
        plugin.visitNamelessApply(namelessApply, context)
        super.visitNamelessApply(namelessApply, context)
    }

    override func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Context) {
        plugin.visitNamelessVariable(namelessVariable, context)
        super.visitNamelessVariable(namelessVariable, context)
    }

    override func visitText(_ text: Text, _ context: Context) {
        plugin.visitText(text, context)
        super.visitText(text, context)
    }

    override func visitContent(_ content: Content, _ context: Context) {
        plugin.visitContent(content, context)
        super.visitContent(content, context)
    }

    override func visitEmphasis(_ emphasis: Emphasis, _ context: Context) {
        plugin.visitEmphasis(emphasis, context)
        super.visitEmphasis(emphasis, context)
    }

    override func visitHeading(_ heading: Heading, _ context: Context) {
        plugin.visitHeading(heading, context)
        super.visitHeading(heading, context)
    }

    override func visitParagraph(_ paragraph: Paragraph, _ context: Context) {
        plugin.visitParagraph(paragraph, context)
        super.visitParagraph(paragraph, context)
    }

    override func visitEquation(_ equation: Equation, _ context: Context) {
        plugin.visitEquation(equation, context)
        super.visitEquation(equation, context)
    }

    override func visitFraction(_ fraction: Fraction, _ context: Context) {
        plugin.visitFraction(fraction, context)
        super.visitFraction(fraction, context)
    }

    override func visitMatrix(_ matrix: Matrix, _ context: Context) {
        plugin.visitMatrix(matrix, context)
        super.visitMatrix(matrix, context)
    }

    override func visitScripts(_ scripts: Scripts, _ context: Context) {
        plugin.visitScripts(scripts, context)
        super.visitScripts(scripts, context)
    }
}
