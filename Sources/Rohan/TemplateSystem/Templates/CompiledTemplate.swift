// Copyright 2024-2025 Lie Yan

import HashTreeCollections

public final class CompiledTemplate {
  let name: TemplateName
  let parameterCount: Int
  let body: [RhExpr]
  let variableLocations: [VariableLocations]

  init(
    _ name: TemplateName,
    _ parameterCount: Int,
    _ body: [RhExpr],
    _ variableLocations: [VariableLocations]
  ) {
    precondition(Self.validate(body: body, parameterCount))
    self.name = name
    self.parameterCount = parameterCount
    self.body = body
    self.variableLocations = variableLocations
  }

  convenience init(
    _ name: TemplateName,
    _ parameterCount: Int,
    _ body: [RhExpr],
    _ variableLocations: Nano.VariableLocationsDict
  ) {
    let varialeLocations = Self.convert(variableLocations, parameterCount)
    self.init(name, parameterCount, body, varialeLocations)
  }

  static func convert(
    _ variableLocations: Nano.VariableLocationsDict, _ parameterCount: Int
  ) -> [VariableLocations] {
    precondition(variableLocations.keys.allSatisfy { $0 < parameterCount })
    var output = [VariableLocations](repeating: .init(), count: parameterCount)
    for (index, locations) in variableLocations {
      output[index] = locations
    }
    return output
  }

  static func validate(body: [RhExpr], _ parameterCount: Int) -> Bool {
    /*
     Conditions to check:
     - contains no apply, whether named or nameless;
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
        return unnamedVariable.index >= parameterCount
      }
      return false
    }

    func disjuntion(_ expression: RhExpr) -> Bool {
      isApply(expression) || isVariable(expression) || isOutOfRange(expression)
    }

    let count = Nano.countExpr(from: body, where: disjuntion(_:))
    return count == 0
  }
}
