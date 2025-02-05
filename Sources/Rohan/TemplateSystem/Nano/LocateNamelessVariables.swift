// Copyright 2024-2025 Lie Yan

import OrderedCollections

extension Nano {
    typealias TreePath = [RohanIndex]
    typealias VariableLocations = OrderedSet<TreePath>

    /** variable index -> variable locations */
    typealias VariableLocationsDict = Dictionary<Int, VariableLocations>

    struct LocateNamelessVariables: NanoPass {
        typealias Input = [Template]
        typealias Output = [AnnotatedTemplate<VariableLocationsDict>]

        static func process(_ input: [Template])
        -> PassResult<[AnnotatedTemplate<VariableLocationsDict>]> {
            let output = input.map { template in
                AnnotatedTemplate(template,
                                  annotation: Self.locateNamelessVariables(in: template))
            }
            return .success(output)
        }

        private static func locateNamelessVariables(in template: Template)
        -> VariableLocationsDict {
            let visitor = LocateNamelessVariablesVisitor()
            visitor.visit(content: template.body, TreePath())
            return visitor.variableLocations
        }
    }

    /**
     Traverse the expression tree, and maintain the tree-path to the current node
     as context.
     */
    private class LocatingVisitor: ExpressionVisitor<TreePath, Void> {
        typealias Context = TreePath

        override func visit(apply: Apply, _ context: Context) {
            preconditionFailure("The input must not contain apply")
        }

        override func visit(variable: Variable, _ context: Context) {
            preconditionFailure("overriding required")
        }

        override func visit(namelessVariable: NamelessVariable, _ context: Context) {
            preconditionFailure("overriding required")
        }

        override func visit(text: Text, _ context: Context) {
            // do nothing
        }

        override func visit(content: Content, _ context: Context) {
            let expressions = content.expressions
            for index in 0 ..< expressions.count {
                let newContext = context + CollectionOfOne(.nodeIndex(index))
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
                let newContext = context + CollectionOfOne(.mathIndex(.numerator))
                visit(content: fraction.numerator, newContext)
            }
            do {
                let newContext = context + CollectionOfOne(.mathIndex(.denominator))
                visit(content: fraction.denominator, newContext)
            }
        }

        override func visit(matrix: Matrix, _ context: Context) {
            for i in 0 ..< matrix.rows.count {
                for j in 0 ..< matrix.rows[i].elements.count {
                    let newContext = context + CollectionOfOne(.gridIndex(i, j))
                    visit(content: matrix.rows[i].elements[j], newContext)
                }
            }
        }

        override func visit(scripts: Scripts, _ context: Context) {
            if let subScript = scripts.subScript {
                let newContext = context + CollectionOfOne(.mathIndex(.subScript))
                visit(content: subScript, newContext)
            }
            if let superScript = scripts.superScript {
                let newContext = context + CollectionOfOne(.mathIndex(.superScript))
                visit(content: superScript, newContext)
            }
        }
    }

    private final class LocateNamelessVariablesVisitor: LocatingVisitor {
        private(set) var variableLocations = VariableLocationsDict()

        override func visit(variable: Variable, _ context: Context) {
            preconditionFailure("The input must not contain variable")
        }

        override func visit(namelessVariable: NamelessVariable, _ context: Context) {
            variableLocations[namelessVariable.index, default: .init()].append(context)
        }
    }
}
