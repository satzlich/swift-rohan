// Copyright 2024 Lie Yan

import Collections
import Foundation

struct CompactTemplates: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    func process(_ input: [Template]) -> PassResult<[Template]> {
        let output = input.map { Self.compactTemplate($0) }
        return .success(output)
    }

    private static func compactTemplate(_ template: Template) -> Template {
        Template(name: template.name,
                 parameters: template.parameters,
                 body: compactContent(template.body))!
    }

    static func compactExpression(_ expression: Expression) -> Expression {
        final class RecursiveCompact: ExpressionRewriter<Void> {
            override func visitContent(_ content: Content, _ context: Void) -> R {
                .content(CompactTemplates.compactContent(content))
            }
        }
        return RecursiveCompact().rewrite(expression, ())
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
                let compacted = compactExpression(expression)
                assert(!compacted.isContent)
                return [compacted]
            }
        }

        // 2) merge neighboring mergeable
        let merged = unnested.reduce(into: [Expression]()) { acc, next in // acc for accumulated
            if let last = acc.last {
                if MergeUtils.isMergeable(last, next) {
                    acc[acc.count - 1] = MergeUtils.mergeMergeable(last, next)
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

    /**
     We want to put all things related to mergeable together.

     Not generalized. Only works for `CompactTemplates`.
     */
    private struct MergeUtils {
        static func isMergeable(_ lhs: Expression, _ rhs: Expression) -> Bool {
            let (left, right) = (lhs.type, rhs.type)
            return left == right && [.text, .content, .emphasis].contains(left)
        }

        static func mergeMergeable(_ lhs: Expression, _ rhs: Expression) -> Expression {
            precondition(isMergeable(lhs, rhs))

            switch (lhs, rhs) {
            case let (.text(lhs), .text(rhs)):
                return .text(lhs + rhs)
            case let (.content(lhs), .content(rhs)):
                return .content(mergeContent(lhs, rhs))
            case let (.emphasis(lhs), .emphasis(rhs)):
                return .emphasis(mergeEmphasis(lhs, rhs))
            default:
                preconditionFailure("Unreachable")
            }
        }

        private static func mergeContent(_ lhs: Content, _ rhs: Content) -> Content {
            func mergeList(_ lhs: [Expression], _ rhs: [Expression]) -> [Expression] {
                guard let l_last = lhs.last else {
                    return rhs
                }
                guard let (r_first, r_suffix) = rhs.splitFirst() else {
                    return lhs
                }

                var res = [Expression]()
                res.reserveCapacity(lhs.count + rhs.count)

                res.append(contentsOf: lhs.dropLast())
                if MergeUtils.isMergeable(l_last, r_first) {
                    res.append(MergeUtils.mergeMergeable(l_last, r_first))
                }
                else {
                    res.append(contentsOf: [l_last, r_first])
                }
                res.append(contentsOf: r_suffix)
                return res
            }

            return Content(expressions: mergeList(lhs.expressions, rhs.expressions))
        }

        private static func mergeEmphasis(_ lhs: Emphasis, _ rhs: Emphasis) -> Emphasis {
            Emphasis(content: mergeContent(lhs.content, rhs.content))
        }
    }
}
