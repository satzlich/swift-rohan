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
        expression is UnnamedVariableExpr
      }
      func isFreeVariable(_ expression: RhExpr) -> Bool {
        if let variable = expression as? VariableExpr {
          return !template.parameters.contains(variable.name)
        }
        return false
      }
      let unamedVariables = Espresso.count(in: template.body, where: isUnnamedVariable(_:))
      let freeVariables = Espresso.count(in: template.body, where: isFreeVariable(_:))
      return unamedVariables == 0 && freeVariables == 0
    }
  }
}
