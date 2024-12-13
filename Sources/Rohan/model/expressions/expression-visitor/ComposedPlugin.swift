// Copyright 2024 Lie Yan

import Foundation

final class ComposedPlugin<P0: ExpressionPlugin, P1: ExpressionPlugin>: ExpressionPlugin
where P0.Context == P1.Context {
    typealias Context = P0.Context

    let p0: P0
    let p1: P1

    init(_ p0: P0, _ p1: P1) {
        self.p0 = p0
        self.p1 = p1
    }

    func visitApply(_ apply: Apply, _ context: Context) {
        p0.visitApply(apply, context)
        p1.visitApply(apply, context)
    }

    func visitVariable(_ variable: Variable, _ context: Context) {
        p0.visitVariable(variable, context)
        p1.visitVariable(variable, context)
    }

    func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Context) {
        p0.visitNamelessApply(namelessApply, context)
        p1.visitNamelessApply(namelessApply, context)
    }

    func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Context) {
        p0.visitNamelessVariable(namelessVariable, context)
        p1.visitNamelessVariable(namelessVariable, context)
    }

    func visitText(_ text: Text, _ context: Context) {
        p0.visitText(text, context)
        p1.visitText(text, context)
    }

    func visitContent(_ content: Content, _ context: Context) {
        p0.visitContent(content, context)
        p1.visitContent(content, context)
    }

    func visitEmphasis(_ emphasis: Emphasis, _ context: Context) {
        p0.visitEmphasis(emphasis, context)
        p1.visitEmphasis(emphasis, context)
    }

    func visitHeading(_ heading: Heading, _ context: Context) {
        p0.visitHeading(heading, context)
        p1.visitHeading(heading, context)
    }

    func visitParagraph(_ paragraph: Paragraph, _ context: Context) {
        p0.visitParagraph(paragraph, context)
        p1.visitParagraph(paragraph, context)
    }

    func visitEquation(_ equation: Equation, _ context: Context) {
        p0.visitEquation(equation, context)
        p1.visitEquation(equation, context)
    }

    func visitFraction(_ fraction: Fraction, _ context: Context) {
        p0.visitFraction(fraction, context)
        p1.visitFraction(fraction, context)
    }

    func visitMatrix(_ matrix: Matrix, _ context: Context) {
        p0.visitMatrix(matrix, context)
        p1.visitMatrix(matrix, context)
    }

    func visitScripts(_ scripts: Scripts, _ context: Context) {
        p0.visitScripts(scripts, context)
        p1.visitScripts(scripts, context)
    }
}
