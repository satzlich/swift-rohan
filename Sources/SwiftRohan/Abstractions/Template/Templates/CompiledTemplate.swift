public final class CompiledTemplate: Codable {
  let name: TemplateName
  var parameterCount: Int { lookup.count }
  let body: Array<Expr>
  let layoutType: LayoutType
  let lookup: Array<VariablePaths>

  convenience init(
    _ name: String, _ body: Array<Expr>, _ layoutType: LayoutType,
    _ lookup: Array<VariablePaths> = []
  ) {
    self.init(TemplateName(name), body, layoutType, lookup)
  }

  init(
    _ name: TemplateName,
    _ body: Array<Expr>,
    _ layoutType: LayoutType,
    _ lookup: Array<VariablePaths>
  ) {
    precondition(CompiledTemplate.validate(body: body, lookup.count))
    self.name = name
    self.body = body
    self.layoutType = layoutType
    self.lookup = lookup
  }

  static func validate(body: Array<Expr>, _ parameterCount: Int) -> Bool {
    /*
     Conditions to check:
     - contains no apply;
     - contains no (named) variables;
     - variable indices are in range
     */

    func isApply(_ expression: Expr) -> Bool {
      expression.type == .apply
    }
    func isVariable(_ expression: Expr) -> Bool {
      expression.type == .variable
    }
    func isOutOfRange(_ expression: Expr) -> Bool {
      if let cVariable = expression as? CompiledVariableExpr {
        return cVariable.argumentIndex >= parameterCount
      }
      return false
    }

    func disjuntion(_ expression: Expr) -> Bool {
      isApply(expression) || isVariable(expression) || isOutOfRange(expression)
    }

    let count = NanoUtils.countExpr(from: body, where: disjuntion(_:))
    return count == 0
  }

  // MARK: - Codable

  enum CodingKeys: CodingKey { case name, body, layoutType, lookup }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(TemplateName.self, forKey: .name)

    var bodyContainer = try container.nestedUnkeyedContainer(forKey: .body)
    body = try ExprSerdeUtils.decodeListOfExprs(from: &bodyContainer)
    layoutType = try container.decode(LayoutType.self, forKey: .layoutType)

    lookup = try container.decode(Array<VariablePaths>.self, forKey: .lookup)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.body, forKey: .body)
    try container.encode(self.layoutType, forKey: .layoutType)
    try container.encode(self.lookup, forKey: .lookup)
  }
}
