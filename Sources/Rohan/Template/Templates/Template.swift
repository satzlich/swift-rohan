// Copyright 2024-2025 Lie Yan

import Foundation

struct Template {
  let name: TemplateName
  let parameters: [Identifier]
  let body: [RhExpr]

  init(name: TemplateName, parameters: [Identifier], body: [RhExpr]) {
    precondition(Template.validate(parameters: parameters))
    self.name = name
    self.parameters = parameters
    self.body = body
  }

  init(name: String, parameters: [String] = [], body: [RhExpr]) {
    self.init(
      name: TemplateName(name), parameters: parameters.map(Identifier.init), body: body)
  }

  func with(body: [RhExpr]) -> Template {
    Template(name: name, parameters: parameters, body: body)
  }

  static func validate(parameters: [Identifier]) -> Bool {
    parameters.count == Set(parameters).count
  }
}
