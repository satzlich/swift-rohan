// Copyright 2024-2025 Lie Yan

import Foundation
import HashTreeCollections

extension Nano {
  struct UnnestContents: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map(UnnestContents.unnestContents(inTemplate:))
      return .success(output)
    }

    private static func unnestContents(inTemplate template: Template) -> Template {
      let flatContent = unnestContents(inContent: ContentExpr(template.body))
      return template.with(body: flatContent.children)
    }

    static func unnestContents(inExpression expression: RhExpr) -> RhExpr {
      /* We prefer to use the rewriter this way in `UnnestContents`
       as embedding `unnestContents(inContent:)` in rewriter is complex. */
      final class UnnestContentsRewriter: ExpressionRewriter<Void> {
        override func visit(content: ContentExpr, _ context: Void) -> R {
          UnnestContents.unnestContents(inContent: content)
        }
      }
      return UnnestContentsRewriter().rewrite(expression, ())
    }

    static func unnestContents(inContent content: ContentExpr) -> ContentExpr {
      let unnested: [RhExpr] =
        content.children.flatMap { expression in
          // for content, recurse and inline
          if let content = expression as? ContentExpr {
            let unnested: ContentExpr = unnestContents(inContent: content)
            return unnested.children
          }
          // for other kinds, we delegate to `unnestContents(inExpression:)`
          else {
            let unnested: RhExpr = unnestContents(inExpression: expression)
            assert(unnested.type != .content)
            return [unnested]
          }
        }
      return content.with(expressions: unnested)
    }
  }
}
