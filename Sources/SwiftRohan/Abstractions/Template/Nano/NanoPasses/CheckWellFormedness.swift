// Copyright 2024 Lie Yan

import Foundation

extension Nano {
  /// Check if the template is well-formed
  struct CheckWellFormedness: NanoPass {
    typealias Input = Array<Template>
    typealias Output = Array<Template>

    static func process(_ input: Input) -> PassResult<Output> {
      input.allSatisfy(isWellFormed(_:)) ? .success(input) : .failure(PassError())
    }

    /// Returns true if template is well-formed.
    static func isWellFormed(_ template: Template) -> Bool {
      // free of compiled variables and "free variables"

      func isCompiledVariable(_ expression: Expr) -> Bool {
        expression.type == .cVariable
      }
      func isFreeVariable(_ expression: Expr) -> Bool {
        guard let variable = expression as? VariableExpr else { return false }
        return template.parameters.contains(variable.name) == false
      }
      func disjunction(_ expr: Expr) -> Bool {
        isCompiledVariable(expr) || isFreeVariable(expr)
      }
      let count = NanoUtils.countExpr(from: template.body, where: disjunction(_:))
      return count == 0
    }
  }
}
