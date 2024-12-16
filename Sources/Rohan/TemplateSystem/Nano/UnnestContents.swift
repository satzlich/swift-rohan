// Copyright 2024 Lie Yan

import Collections
import Foundation

extension Nano {
    struct UnnestContents: NanoPass {
        typealias Input = [Template]
        typealias Output = [Template]

        static func process(_ input: [Template]) -> PassResult<[Template]> {
            let output = input.map { template in
                Self.unnestContents(inTemplate: template)
            }
            return .success(output)
        }

        private static func unnestContents(inTemplate template: Template) -> Template {
            let body = unnestContents(inContent: template.body)
            return template.with(body: body)
        }

        static func unnestContents(inExpression expression: Expression) -> Expression {
            /*
             We prefer to use the rewriter this way in `UnnestContents`
             as embedding `unnestContents(inContent:)` in rewriter is complex.
             */
            final class UnnestContentsRewriter: ExpressionRewriter<Void> {
                override func visit(content: Content, _ context: Void) -> R {
                    .content(UnnestContents.unnestContents(inContent: content))
                }
            }
            return UnnestContentsRewriter().rewrite(expression: expression, ())
        }

        static func unnestContents(inContent content: Content) -> Content {
            let unnested = content.expressions.flatMap { expression in
                // for content, recurse and inline
                if case let .content(content) = expression {
                    let unnested = unnestContents(inContent: content)
                    return unnested.expressions
                }
                // for other kinds, we delegate to `unnestContents(inExpression:)`
                else {
                    let unnested = unnestContents(inExpression: expression)
                    assert(unnested.type != .content)
                    return [unnested]
                }
            }
            return content.with(expressions: unnested)
        }
    }
}
