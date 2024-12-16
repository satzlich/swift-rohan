// Copyright 2024 Lie Yan

import Collections

extension Nano {
    struct LocateNamedVariables: NanoPass {
        /**
         variable name -> variable use paths
         */
        typealias VariablePathsDict = Dictionary<Identifier, OrderedSet<TreePath>>

        typealias Input = [Template]
        typealias Output = [AnnotatedTemplate<VariablePathsDict>]

        func process(_ input: [Template]) -> PassResult<[AnnotatedTemplate<VariablePathsDict>]> {
            let output = input.map { template in
                AnnotatedTemplate(template,
                                  annotation: Self.locateNamedVariables(in: template))
            }
            return .success(output)
        }

        private static func locateNamedVariables(in template: Template) -> VariablePathsDict {
            let visitor = LocateNamedVariablesVisitor()
            visitor.visit(content: template.body, TreePath())
            return visitor.variableUses
        }

        private typealias Context = TreePath
    }

    private class LocateVariablesVisitor: ExpressionVisitor<TreePath, Void> {
        typealias Context = TreePath

        override func visit(apply: Apply, _ context: Context) {
            preconditionFailure("The input must not contain apply")
        }

        override func visit(variable: Variable, _ context: Context) {
            preconditionFailure("Must be overridden in subclasses")
        }

        override func visit(namelessApply: NamelessApply, _ context: Context) {
            preconditionFailure("The input must not contain nameless apply")
        }

        override func visit(namelessVariable: NamelessVariable, _ context: Context) {
            preconditionFailure("Must be overridden in subclasses")
        }

        override func visit(text: Text, _ context: Context) {
            // do nothing
        }

        override func visit(content: Content, _ context: Context) {
            let expressions = content.expressions
            for index in 0 ..< expressions.count {
                let newContext = context.appended(.arrayIndex(index))
                visit(expression: expressions[index], newContext)
            }
        }

        override func visit(emphasis: Emphasis, _ context: Context) {
            visit(content: emphasis.content, context)
        }

        override func visit(heading: Heading, _ context: Context) {
            visit(content: heading.content, context)
        }

        override func visit(paragraph: Paragraph, _ context: Context) {
            visit(content: paragraph.content, context)
        }

        override func visit(equation: Equation, _ context: Context) {
            visit(content: equation.content, context)
        }

        override func visit(fraction: Fraction, _ context: Context) {
            do {
                let newContext = context.appended(.mathIndex(.numerator))
                visit(content: fraction.numerator, newContext)
            }
            do {
                let newContext = context.appended(.mathIndex(.denominator))
                visit(content: fraction.denominator, newContext)
            }
        }

        override func visit(matrix: Matrix, _ context: Context) {
            for i in 0 ..< matrix.rows.count {
                for j in 0 ..< matrix.rows[i].elements.count {
                    let newContext = context.appended(.gridIndex(row: i, column: j))
                    visit(content: matrix.rows[i].elements[j], newContext)
                }
            }
        }

        override func visit(scripts: Scripts, _ context: Context) {
            if let subScript = scripts.subScript {
                let newContext = context.appended(.mathIndex(.subScript))
                visit(content: subScript, newContext)
            }
            if let superScript = scripts.superScript {
                let newContext = context.appended(.mathIndex(.superScript))
                visit(content: superScript, newContext)
            }
        }
    }

    private final class LocateNamedVariablesVisitor: LocateVariablesVisitor {
        private(set) var variableUses = Dictionary<Identifier, OrderedSet<TreePath>>()

        override func visit(variable: Variable, _ context: Context) {
            variableUses[variable.name, default: .init()].append(context)
        }

        override func visit(namelessVariable: NamelessVariable, _ context: Context) {
            preconditionFailure("The input must not contain nameless variable")
        }
    }

    private final class LocateNamelessVariablesVisitor: LocateVariablesVisitor {
        private(set) var variableUses = Dictionary<Int, OrderedSet<TreePath>>()

        override func visit(variable: Variable, _ context: Context) {
            preconditionFailure("The input must not contain variable")
        }

        override func visit(namelessVariable: NamelessVariable, _ context: Context) {
            variableUses[namelessVariable.index, default: .init()].append(context)
        }
    }
}
