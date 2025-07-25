extension Nano {
  struct MergeNeighbours: NanoPass {
    typealias Input = Array<Template>
    typealias Output = Array<Template>

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
        let merged = content.children.reduce(into: Array<Expr>()) { acc, next in
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

        return content.with(children: merged)
      }
    }
  }

  /// We want to put all things related to mergeable together.
  /// __Not generalized__. Only works for `MergeNeighbours`.
  private struct MergeUtils {
    static func isMergeable(_ lhs: Expr, _ rhs: Expr) -> Bool {
      let (left, right) = (lhs.type, rhs.type)

      if left == right {
        if [ExprType.text, .content].contains(left) {
          return true
        }

        if let lhs = lhs as? TextStylesExpr,
          let rhs = rhs as? TextStylesExpr,
          lhs.subtype == rhs.subtype
        {
          return true
        }
        // FALL THROUGH
      }
      return false
    }

    static func mergeMergeable(_ lhs: Expr, _ rhs: Expr) -> Expr {
      precondition(isMergeable(lhs, rhs))
      switch (lhs, rhs) {
      case let (lhs as TextExpr, rhs as TextExpr):
        return lhs + rhs
      case let (lhs as ElementExpr, rhs as ElementExpr):
        return mergeElement(lhs, rhs)
      default:
        // This should never happen, because we have checked the types.
        preconditionFailure("unreachable")
      }
    }

    private static func mergeElement(
      _ lhs: ElementExpr, _ rhs: ElementExpr
    ) -> ElementExpr {
      precondition(isMergeable(lhs, rhs))
      let merged = mergeLists(lhs.children, rhs.children)
      return lhs.with(children: merged)
    }

    /// Merge two lists of expressions.
    private static func mergeLists(
      _ lhs: Array<Expr>, _ rhs: Array<Expr>
    ) -> Array<Expr> {
      if lhs.isEmpty { return rhs }
      if rhs.isEmpty { return lhs }

      let l_last = lhs.last!
      let r_first = rhs.first!
      if isMergeable(l_last, r_first) {
        var res = Array<Expr>()
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
