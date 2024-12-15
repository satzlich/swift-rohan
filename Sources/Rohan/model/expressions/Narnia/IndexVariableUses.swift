// Copyright 2024 Lie Yan

extension Narnia {
    struct IndexVariableUses: NanoPass {
        typealias Input = [Template]
        typealias Output = [AnnotatedTemplate<VariableUses>]

        func process(input: [Template]) -> PassResult<[AnnotatedTemplate<VariableUses>]> {
            let output = input.map { template in
                AnnotatedTemplate(template,
                                  annotation: Self.indexVariableUses(in: template))
            }
            return .success(output)
        }

        private static func indexVariableUses(in template: Template) -> VariableUses {
            let visitor = AnalyseVariableUsesVisitor()
            visitor.visit(content: template.body, TreePath())
            return visitor.variableUses
        }

        private typealias Context = TreePath

        private final class AnalyseVariableUsesVisitor: ExpressionVisitor<Context, Void> {
            private(set) var variableUses: VariableUses = .init()

            override func visit(apply: Apply, _ context: Context) {
                preconditionFailure("Should not be called")
            }

            override func visit(variable: Variable, _ context: Context) {
                variableUses[variable.name, default: .init()].append(context)
            }

            override func visit(namelessApply: NamelessApply, _ context: Context) {
                preconditionFailure("Should not be called")
            }

            override func visit(namelessVariable: NamelessVariable, _ context: Context) {
                preconditionFailure("Should not be called")
            }

            override func visit(text: Text, _ context: Context) {
                // do nothing
            }

            override func visit(content: Content, _ context: Context) {
                let expressions = content.expressions
                for index in 0 ..< expressions.count {
                    let newContext = context.appended(.regular(index))
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
                // TODO:
            }

            override func visit(matrix: Matrix, _ context: Context) {
                // TODO:
            }

            override func visit(scripts: Scripts, _ context: Context) {
                // TODO:
            }
        }
    }
}
