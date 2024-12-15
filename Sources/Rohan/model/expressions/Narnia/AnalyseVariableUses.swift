// Copyright 2024 Lie Yan

extension Narnia {
    struct AnalyseVariableUses: NanoPass {
        typealias Input = [Template]
        typealias Output = [AnnotatedTemplate<VariableUses>]

        func process(input: [Template]) -> PassResult<[AnnotatedTemplate<VariableUses>]> {
            let output = input.map { template in
                AnnotatedTemplate(template,
                                  annotation: Self.indexVariableUses(template))
            }
            return .success(output)
        }

        private static func indexVariableUses(_ template: Template) -> VariableUses {
            let visitor = AnalyseVariableUsesVisitor()
            visitor.visit(content: template.body, TreePath())
            return visitor.variableUses
        }

        private typealias Context = TreePath

        private final class AnalyseVariableUsesVisitor: UntutoredExpressionVisitor<Context> {
            private(set) var variableUses: VariableUses = .init()

            override func visit(content: Content, _ context: Context) {
                let expressions = content.expressions
                for index in 0 ..< expressions.count {
                    let newContext = context.appended(.regular(index))
                    visit(expression: expressions[index], newContext)
                }
            }

            override func visit(variable: Variable, _ context: Context) {
                variableUses[variable.name, default: .init()].append(context)
            }

            // visit math
        }
    }
}
