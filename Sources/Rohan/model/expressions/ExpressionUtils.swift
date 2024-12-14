// Copyright 2024 Lie Yan

import Foundation

enum ExpressionUtils {
    static func compactExpression(_ expression: Expression) -> Expression {
        final class RewriteWithCompact: ExpressionRewriter<Void> {
            override func visitContent(_ content: Content, _ context: Void) -> R {
                .content(ExpressionUtils.compactContent(content))
            }
        }
        return RewriteWithCompact().rewrite(expression, ())
    }

    static func compactContent(_ content: Content) -> Content {
        // 1) unnest contents
        let unnested = content.expressions.flatMap { expression in
            // for content, recurse and inline
            if case let .content(content) = expression {
                let compacted = compactContent(content)
                return compacted.expressions
            }
            // for other kinds, we must recurse
            else {
                return [compactExpression(expression)]
            }
        }

        // 2) merge texts
        let merged = unnested.reduce(into: [Expression]()) { acc, next in // acc for accumulated
            if let last = acc.last {
                if case let .text(lastText) = last,
                   case let .text(nextText) = next
                {
                    acc[acc.count - 1] = .text(lastText + nextText)
                }
                else {
                    acc.append(next)
                }
            }
            else {
                acc.append(next)
            }
        }

        return Content(expressions: merged)
    }
}
