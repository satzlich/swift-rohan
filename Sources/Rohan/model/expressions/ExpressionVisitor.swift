// Copyright 2024 Lie Yan

import Cocoa
import Foundation

class ExpressionVisitor<C> {
    var context: C

    init(_ context: C) {
        self.context = context
    }

    convenience init() where C: DefaultConstructible {
        self.init(C())
    }

    func visitApply(_ apply: Apply) {
        for argument in apply.arguments {
            visitContent(argument)
        }
    }

    func visitVariable(_ variable: Variable) {
        // do nothing
    }

    func visitNamelessApply(_ namelessApply: NamelessApply) {
        for argument in namelessApply.arguments {
            visitContent(argument)
        }
    }

    func visitNamelessVariable(_ namelessVariable: NamelessVariable) {
        // do nothing
    }

    func visitText(_ text: Text) {
        // do nothing
    }

    func visitContent(_ content: Content) {
        for expression in content.expressions {
            expression.accept(self)
        }
    }

    func visitEmphasis(_ emphasis: Emphasis) {
        visitContent(emphasis.content)
    }

    func visitHeading(_ heading: Heading) {
        visitContent(heading.content)
    }

    func visitParagraph(_ paragraph: Paragraph) {
        visitContent(paragraph.content)
    }

    func visitEquation(_ equation: Equation) {
        visitContent(equation.content)
    }

    func visitFraction(_ fraction: Fraction) {
        visitContent(fraction.numerator)
        visitContent(fraction.denominator)
    }

    func visitMatrix(_ matrix: Matrix) {
        for row in matrix.rows {
            for element in row.elements {
                visitContent(element)
            }
        }
    }

    func visitScripts(_ scripts: Scripts) {
        if let `subscript` = scripts.subscript {
            visitContent(`subscript`)
        }
        if let superscript = scripts.superscript {
            visitContent(superscript)
        }
    }

    // MARK: - Utilities

    func invoke(_ expression: Expression) -> C {
        expression.accept(self)
        return context
    }

    func invoke(_ content: Content) -> C {
        visitContent(content)
        return context
    }
}

extension Expression {
    func accept<C>(_ visitor: ExpressionVisitor<C>) {
        switch self {
        case let .apply(apply):
            visitor.visitApply(apply)
        case let .variable(variable):
            visitor.visitVariable(variable)
        case let .namelessApply(namelessApply):
            visitor.visitNamelessApply(namelessApply)
        case let .namelessVariable(namelessVariable):
            visitor.visitNamelessVariable(namelessVariable)
        case let .text(text):
            visitor.visitText(text)
        case let .content(content):
            visitor.visitContent(content)
        case let .emphasis(emphasis):
            visitor.visitEmphasis(emphasis)
        case let .heading(heading):
            visitor.visitHeading(heading)
        case let .paragraph(paragraph):
            visitor.visitParagraph(paragraph)
        case let .equation(equation):
            visitor.visitEquation(equation)
        case let .fraction(fraction):
            visitor.visitFraction(fraction)
        case let .matrix(matrix):
            visitor.visitMatrix(matrix)
        case let .scripts(scripts):
            visitor.visitScripts(scripts)
        }
    }
}
