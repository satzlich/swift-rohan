// Copyright 2024 Lie Yan

import Collections
import Foundation

extension Narnia {
    struct UnnestContents: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        func process(_ input: [Template]) -> PassResult<[Template]> {
            let output = input.map { Self.unnestContents(inTemplate: $0) }
            return .success(output)
        }

        private static func unnestContents(inTemplate template: Template) -> Template {
            Template(name: template.name,
                     parameters: template.parameters,
                     body: unnestContents(inContent: template.body))!
        }

        static func unnestContents(inExpression expression: Expression) -> Expression {
            /*
             We prefer to use the rewriter this way.
             */
            final class UnnestContentsRewriter: ExpressionRewriter<Void> {
                override func visitContent(_ content: Content, _ context: Void) -> R {
                    .content(UnnestContents.unnestContents(inContent: content))
                }
            }
            return UnnestContentsRewriter().rewrite(expression, ())
        }

        static func unnestContents(inContent content: Content) -> Content {
            let unnested = content.expressions.flatMap { expression in
                // for content, recurse and inline
                if case let .content(content) = expression {
                    let compacted = unnestContents(inContent: content)
                    return compacted.expressions
                }
                // for other kinds, we delegate to `unnestContents`
                else {
                    let compacted = unnestContents(inExpression: expression)
                    assert(compacted.type != .content)
                    return [compacted]
                }
            }
            return content.with(expressions: unnested)
        }
    }
}
