// Copyright 2024-2025 Lie Yan

extension Nano {
  struct MergeNeighbours: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map(MergeNeighbours.mergeNeighbours(in:))
      return .success(output)
    }

    private static func mergeNeighbours(in template: Template) -> Template {
      let rewriter = MergeNeighboursRewriter()
      let content = rewriter.rewrite(ContentExpr(template.body), ()) as! ContentExpr
      return template.with(body: content.children)
    }

    private final class MergeNeighboursRewriter: ExpressionRewriter<Void> {
      override func visit(content: ContentExpr, _ context: Void) -> R {
        let merged = content.children.reduce(into: [RhExpr]()) { acc, next in
          // a) recurse
          let next = self.rewrite(next, context)

          // b) merge or append
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

        return content.with(expressions: merged)
      }
    }
  }

  /**  We want to put all things related to mergeable together.
   __Not generalized.__ Only works for `MergeNeighbours`. */
  private struct MergeUtils {
    static func isMergeable(_ lhs: RhExpr, _ rhs: RhExpr) -> Bool {
      let (left, right) = (lhs.type, rhs.type)
      let mergeable = [ExprType.text, .content, .emphasis]
      return left == right && mergeable.contains(left)
    }

    static func mergeMergeable(_ lhs: RhExpr, _ rhs: RhExpr) -> RhExpr {
      precondition(isMergeable(lhs, rhs))
      switch (lhs, rhs) {
      case let (lhs as TextExpr, rhs as TextExpr):
        return lhs + rhs
      case let (lhs as ElementExpr, rhs as ElementExpr):
        return mergeElement(lhs, rhs)
      default:
        preconditionFailure("unreachable")
      }
    }

    private static func mergeElement(_ lhs: ElementExpr, _ rhs: ElementExpr) -> ElementExpr {
      precondition(isMergeable(lhs, rhs))
      let merged = mergeLists(lhs.children, rhs.children)
      return lhs.with(expressions: merged)
    }

    /** Merge two lists. */
    private static func mergeLists(
      _ lhs: [RhExpr], _ rhs: [RhExpr]
    ) -> [RhExpr] {
      if lhs.isEmpty { return rhs }
      if rhs.isEmpty { return lhs }

      let l_last = lhs[lhs.count - 1]
      let r_first = rhs[0]
      if isMergeable(l_last, r_first) {
        var res = [RhExpr]()
        res.reserveCapacity(lhs.count + rhs.count - 1)
        res.append(contentsOf: lhs.dropLast())
        res.append(mergeMergeable(l_last, r_first))
        res.append(contentsOf: rhs.dropFirst())
        return res
      }
      else {
        return lhs + rhs
      }
    }
  }
}
