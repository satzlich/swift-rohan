// Copyright 2024-2025 Lie Yan

import Foundation

struct Template: Codable {
  let name: TemplateName
  let parameters: Array<Identifier>
  let body: Array<Expr>

  init(name: TemplateName, parameters: Array<Identifier>, body: Array<Expr>) {
    precondition(Template.validate(parameters: parameters))
    self.name = name
    self.parameters = parameters
    self.body = body
  }

  init(name: String, parameters: Array<String> = [], body: Array<Expr>) {
    let name = TemplateName(name)
    let parameters = parameters.map { Identifier($0) }

    self.init(name: name, parameters: parameters, body: body)
  }

  func with(body: Array<Expr>) -> Template {
    Template(name: name, parameters: parameters, body: body)
  }

  static func validate(parameters: Array<Identifier>) -> Bool {
    parameters.count == Set(parameters).count
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case name, parameters, body }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(TemplateName.self, forKey: .name)
    self.parameters = try container.decode(Array<Identifier>.self, forKey: .parameters)
    var bodyContainer = try container.nestedUnkeyedContainer(forKey: .body)
    self.body = try ExprSerdeUtils.decodeListOfExprs(from: &bodyContainer)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.parameters, forKey: .parameters)
    try container.encode(self.body, forKey: .body)
  }
}
