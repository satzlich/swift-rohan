// Copyright 2024 Lie Yan

class ExpressionVisitorPlugin<C>: ExpressionVisitorBase<C> {
}

final class ExpressionPluginVisitor<C>: ExpressionVisitor<C> {
    let plugins: [ExpressionVisitorPlugin<C>]

    init(_ plugins: [ExpressionVisitorPlugin<C>]) {
        self.plugins = plugins
    }

    override func visitApply(_ apply: Apply, _ context: C) {
        for plugin in plugins {
            plugin.visitApply(apply, context)
        }
        super.visitApply(apply, context)
    }

    override func visitVariable(_ variable: Variable, _ context: C) {
        for plugin in plugins {
            plugin.visitVariable(variable, context)
        }
        super.visitVariable(variable, context)
    }

    override func visitNamelessApply(_ namelessApply: NamelessApply, _ context: C) {
        for plugin in plugins {
            plugin.visitNamelessApply(namelessApply, context)
        }
        super.visitNamelessApply(namelessApply, context)
    }

    override func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: C) {
        for plugin in plugins {
            plugin.visitNamelessVariable(namelessVariable, context)
        }
        super.visitNamelessVariable(namelessVariable, context)
    }

    override func visitText(_ text: Text, _ context: C) {
        for plugin in plugins {
            plugin.visitText(text, context)
        }
        super.visitText(text, context)
    }

    override func visitContent(_ content: Content, _ context: C) {
        for plugin in plugins {
            plugin.visitContent(content, context)
        }
        super.visitContent(content, context)
    }

    override func visitEmphasis(_ emphasis: Emphasis, _ context: C) {
        for plugin in plugins {
            plugin.visitEmphasis(emphasis, context)
        }
        super.visitEmphasis(emphasis, context)
    }

    override func visitHeading(_ heading: Heading, _ context: C) {
        for plugin in plugins {
            plugin.visitHeading(heading, context)
        }
        super.visitHeading(heading, context)
    }

    override func visitParagraph(_ paragraph: Paragraph, _ context: C) {
        for plugin in plugins {
            plugin.visitParagraph(paragraph, context)
        }
        super.visitParagraph(paragraph, context)
    }

    override func visitEquation(_ equation: Equation, _ context: C) {
        for plugin in plugins {
            plugin.visitEquation(equation, context)
        }
        super.visitEquation(equation, context)
    }

    override func visitFraction(_ fraction: Fraction, _ context: C) {
        for plugin in plugins {
            plugin.visitFraction(fraction, context)
        }
        super.visitFraction(fraction, context)
    }

    override func visitMatrix(_ matrix: Matrix, _ context: C) {
        for plugin in plugins {
            plugin.visitMatrix(matrix, context)
        }
        super.visitMatrix(matrix, context)
    }

    override func visitScripts(_ scripts: Scripts, _ context: C) {
        for plugin in plugins {
            plugin.visitScripts(scripts, context)
        }
        super.visitScripts(scripts, context)
    }
}
