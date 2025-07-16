// Copyright 2024-2025 Lie Yan

extension Nano {
  /// Compute nested level delta for each variable in the template.
  struct ComputeNestedLevelDelta: NanoPass {
    typealias Input = Array<Template>
    typealias Output = Array<Template>

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map(computeNestedLevelDelta(_:))
      return .success(output)
    }
  }

  private static func computeNestedLevelDelta(_ template: Template) -> Template {
    let rewriter = NestedLevelDeltaRewriter()
    let body = rewriter.rewrite(template.body, 0)
    return template.with(body: body)
  }

  private final class NestedLevelDeltaRewriter: ExpressionRewriter<Int> {
    override func nextLevelContext(_ expr: Expr, _ context: Int) -> Int {
      NodePolicy.shouldIncreaseLevel(expr.type)
        ? context + 1
        : context
    }

    override func visit(cVariable: CompiledVariableExpr, _ context: Int) -> R {
      cVariable.with(nestedLevelDelta: context)
    }

    override func visit(variable: VariableExpr, _ context: Int) -> R {
      assertionFailure("VariableExpr should not be visited")
      return variable
    }
  }
}
