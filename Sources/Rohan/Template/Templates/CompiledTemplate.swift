// Copyright 2024-2025 Lie Yan

public final class CompiledTemplate {
  let name: TemplateName
  var parameterCount: Int { variablePaths.count }
  let body: [RhExpr]
  let variablePaths: [VariablePaths]

  convenience init(
    _ name: String, _ body: [RhExpr], _ variablePaths: [VariablePaths] = []
  ) {
    self.init(TemplateName(name), body, variablePaths)
  }

  init(_ name: TemplateName, _ body: [RhExpr], _ variablePaths: [VariablePaths]) {
    precondition(Self.validate(body: body, variablePaths.count))
    self.name = name
    self.body = body
    self.variablePaths = variablePaths
  }

  static func validate(body: [RhExpr], _ parameterCount: Int) -> Bool {
    /*
     Conditions to check:
     - contains no apply;
     - contains no named variables;
     - variable indices are in range
     */

    func isApply(_ expression: RhExpr) -> Bool {
      expression.type == .apply
    }
    func isVariable(_ expression: RhExpr) -> Bool {
      expression.type == .variable
    }
    func isOutOfRange(_ expression: RhExpr) -> Bool {
      if let unnamedVariable = expression as? UnnamedVariableExpr {
        return unnamedVariable.argumentIndex >= parameterCount
      }
      return false
    }

    func disjuntion(_ expression: RhExpr) -> Bool {
      isApply(expression) || isVariable(expression) || isOutOfRange(expression)
    }

    let count = NanoUtils.countExpr(from: body, where: disjuntion(_:))
    return count == 0
  }
}
