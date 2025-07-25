import Foundation

struct Template: Codable {
  let name: TemplateName
  let parameters: Array<Identifier>
  let body: Array<Expr>
  let layoutType: LayoutType

  init(
    name: TemplateName, parameters: Array<Identifier>, body: Array<Expr>,
    layoutType: LayoutType
  ) {
    precondition(Template.validate(parameters: parameters))
    self.name = name
    self.parameters = parameters
    self.body = body
    self.layoutType = layoutType
  }

  init(
    name: String, parameters: Array<String> = [], body: Array<Expr>,
    layoutType: LayoutType
  ) {
    let name = TemplateName(name)
    let parameters = parameters.map { Identifier($0) }
    self.init(name: name, parameters: parameters, body: body, layoutType: layoutType)
  }

  func with(body: Array<Expr>) -> Template {
    Template(name: name, parameters: parameters, body: body, layoutType: layoutType)
  }

  static func validate(parameters: Array<Identifier>) -> Bool {
    parameters.count == Set(parameters).count
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case name, parameters, body, layoutType }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(TemplateName.self, forKey: .name)
    self.parameters = try container.decode(Array<Identifier>.self, forKey: .parameters)
    var bodyContainer = try container.nestedUnkeyedContainer(forKey: .body)
    self.body = try ExprSerdeUtils.decodeListOfExprs(from: &bodyContainer)
    self.layoutType = try container.decode(LayoutType.self, forKey: .layoutType)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.parameters, forKey: .parameters)
    try container.encode(self.body, forKey: .body)
    try container.encode(self.layoutType, forKey: .layoutType)
  }
}
