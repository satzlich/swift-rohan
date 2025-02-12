// Copyright 2024-2025 Lie Yan

extension Nano {
  struct MergeNeighbours: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func process(_ input: [Template]) -> PassResult<[Template]> {
      let output = input.map(MergeNeighbours.mergeNeighbours(in:))
      return .success(output)
    }

    private static func mergeNeighbours(in template: Template) -> Template {
      let body = MergeNeighboursRewriter().rewrite(content: template.body, ())
      return template.with(body: body)
    }

    private final class MergeNeighboursRewriter: ExpressionRewriter<Void> {
      override func visit(content: Content, _ context: Void) -> R {
        let merged = content.expressions.reduce(into: [Expression]()) { acc, next in
          // a) recurse
          let next = self.rewrite(expression: next, context)

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

        return .content(content.with(expressions: merged))
      }
    }
  }

  /**
     We want to put all things related to mergeable together.

     Not generalized. Only works for `MergeNeighbours`.
     */
  private struct MergeUtils {
    static func isMergeable(_ lhs: Expression, _ rhs: Expression) -> Bool {
      let (left, right) = (lhs.type, rhs.type)

      return left == right
        && [
          .text,
          .content,
          .emphasis,
        ].contains(left)
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
        preconditionFailure("Must be unreachable")
      }
    }

    private static func mergeContent(_ lhs: Content, _ rhs: Content) -> Content {
      return Content(expressions: mergeLists(lhs.expressions, rhs.expressions))
    }

    /**
         Merge two lists.
         */
    private static func mergeLists(
      _ lhs: [Expression], _ rhs: [Expression]
    ) -> [Expression] {
      if lhs.isEmpty {
        return rhs
      }
      if rhs.isEmpty {
        return lhs
      }

      let l_last = lhs[lhs.count - 1]
      let r_first = rhs[0]
      if isMergeable(l_last, r_first) {
        var res = [Expression]()
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

    private static func mergeEmphasis(_ lhs: Emphasis, _ rhs: Emphasis) -> Emphasis {
      Emphasis(content: mergeContent(lhs.content, rhs.content))
    }
  }
}
