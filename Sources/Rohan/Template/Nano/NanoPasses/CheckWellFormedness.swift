// Copyright 2024 Lie Yan

import Foundation

extension Nano {
  /** Check if the template is well-formed */
  struct CheckWellFormedness: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func process(_ input: Input) -> PassResult<Output> {
      input.allSatisfy(isWellFormed(_:)) ? .success(input) : .failure(PassError())
    }

    /** Returns true if template is well-formed. */
    static func isWellFormed(_ template: Template) -> Bool {
      // free of unnamed variables and "free variables"

      func isUnnamedVariable(_ expression: RhExpr) -> Bool {
        expression.type == .cVariable
      }
      func isFreeVariable(_ expression: RhExpr) -> Bool {
        guard let variable = expression as? VariableExpr else { return false }
        return !template.parameters.contains(variable.name)
      }
      func disjunction(_ expr: RhExpr) -> Bool {
        isUnnamedVariable(expr) || isFreeVariable(expr)
      }
      let count = NanoUtils.countExpr(from: template.body, where: disjunction(_:))
      return count == 0
    }
  }
}
