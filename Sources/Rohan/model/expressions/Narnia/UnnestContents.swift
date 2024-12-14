// Copyright 2024 Lie Yan

import Collections
import Foundation

extension Narnia {
    struct UnnestContents: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        func process(_ input: [Template]) -> PassResult<[Template]> {
            let output = input.map { Self.unnestContents(in: $0) }
            return .success(output)
        }

        private static func unnestContents(in template: Template) -> Template {
            Template(name: template.name,
                     parameters: template.parameters,
                     body: unnestContent(template.body))!
        }

        static func unnestContents(in expression: Expression) -> Expression {
            final class RecurseUnnestRewriter: ExpressionRewriter<Void> {
                override func visitContent(_ content: Content, _ context: Void) -> R {
                    .content(UnnestContents.unnestContent(content))
                }
            }
            return RecurseUnnestRewriter().rewrite(expression, ())
        }

        static func unnestContent(_ content: Content) -> Content {
            let unnested = content.expressions.flatMap { expression in
                // for content, recurse and inline
                if case let .content(content) = expression {
                    let compacted = unnestContent(content)
                    return compacted.expressions
                }
                // for other kinds, we delegate to `unnestContents`
                else {
                    let compacted = unnestContents(in: expression)
                    assert(compacted.type != .content)
                    return [compacted]
                }
            }
            return Content(expressions: unnested)
        }
    }
}
