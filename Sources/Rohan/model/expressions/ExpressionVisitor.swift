// Copyright 2024 Lie Yan

import Cocoa
import Foundation

class ExpressionVisitorBase<C> {
    func visitApply(_ apply: Apply, _ context: C) {
        // do nothing
    }

    func visitVariable(_ variable: Variable, _ context: C) {
        // do nothing
    }

    func visitNamelessApply(_ namelessApply: NamelessApply, _ context: C) {
        // do nothing
    }

    func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: C) {
        // do nothing
    }

    func visitText(_ text: Text, _ context: C) {
        // do nothing
    }

    func visitContent(_ content: Content, _ context: C) {
        // do nothing
    }

    func visitEmphasis(_ emphasis: Emphasis, _ context: C) {
        // do nothing
    }

    func visitHeading(_ heading: Heading, _ context: C) {
        // do nothing
    }

    func visitParagraph(_ paragraph: Paragraph, _ context: C) {
        // do nothing
    }

    func visitEquation(_ equation: Equation, _ context: C) {
        // do nothing
    }

    func visitFraction(_ fraction: Fraction, _ context: C) {
        // do nothing
    }

    func visitMatrix(_ matrix: Matrix, _ context: C) {
        // do nothing
    }

    func visitScripts(_ scripts: Scripts, _ context: C) {
        // do nothing
    }
}

class ExpressionVisitor<C>: ExpressionVisitorBase<C> {
    override func visitApply(_ apply: Apply, _ context: C) {
        for argument in apply.arguments {
            visitContent(argument, context)
        }
    }

    override func visitVariable(_ variable: Variable, _ context: C) {
        // do nothing
    }

    override func visitNamelessApply(_ namelessApply: NamelessApply, _ context: C) {
        for argument in namelessApply.arguments {
            visitContent(argument, context)
        }
    }

    override func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: C) {
        // do nothing
    }

    override func visitText(_ text: Text, _ context: C) {
        // do nothing
    }

    override func visitContent(_ content: Content, _ context: C) {
        for expression in content.expressions {
            expression.accept(self, context)
        }
    }

    override func visitEmphasis(_ emphasis: Emphasis, _ context: C) {
        visitContent(emphasis.content, context)
    }

    override func visitHeading(_ heading: Heading, _ context: C) {
        visitContent(heading.content, context)
    }

    override func visitParagraph(_ paragraph: Paragraph, _ context: C) {
        visitContent(paragraph.content, context)
    }

    override func visitEquation(_ equation: Equation, _ context: C) {
        visitContent(equation.content, context)
    }

    override func visitFraction(_ fraction: Fraction, _ context: C) {
        visitContent(fraction.numerator, context)
        visitContent(fraction.denominator, context)
    }

    override func visitMatrix(_ matrix: Matrix, _ context: C) {
        for row in matrix.rows {
            for element in row.elements {
                visitContent(element, context)
            }
        }
    }

    override func visitScripts(_ scripts: Scripts, _ context: C) {
        if let `subscript` = scripts.subscript {
            visitContent(`subscript`, context)
        }
        if let superscript = scripts.superscript {
            visitContent(superscript, context)
        }
    }
}

extension Expression {
    func accept<C>(_ visitor: ExpressionVisitor<C>, _ context: C) {
        switch self {
        case let .apply(apply):
            visitor.visitApply(apply, context)
        case let .variable(variable):
            visitor.visitVariable(variable, context)
        case let .namelessApply(namelessApply):
            visitor.visitNamelessApply(namelessApply, context)
        case let .namelessVariable(namelessVariable):
            visitor.visitNamelessVariable(namelessVariable, context)
        case let .text(text):
            visitor.visitText(text, context)
        case let .content(content):
            visitor.visitContent(content, context)
        case let .emphasis(emphasis):
            visitor.visitEmphasis(emphasis, context)
        case let .heading(heading):
            visitor.visitHeading(heading, context)
        case let .paragraph(paragraph):
            visitor.visitParagraph(paragraph, context)
        case let .equation(equation):
            visitor.visitEquation(equation, context)
        case let .fraction(fraction):
            visitor.visitFraction(fraction, context)
        case let .matrix(matrix):
            visitor.visitMatrix(matrix, context)
        case let .scripts(scripts):
            visitor.visitScripts(scripts, context)
        }
    }
}
