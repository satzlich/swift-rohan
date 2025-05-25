// Copyright 2024-2025 Lie Yan

import Foundation

struct MathTemplate: CommandDeclarationProtocol {
  enum Subtype: String, Codable {
    /// For function call, a call to the template is output for storage.
    case functionCall
    /// For code snippet, the expanded content is output for storage.
    case codeSnippet
  }

  var command: String { template.name.identifier.name }
  let template: CompiledTemplate
  let subtype: Subtype

  var name: TemplateName { template.name }
  var parameterCount: Int { template.parameterCount }

  init(_ template: CompiledTemplate, subtype: Subtype = .functionCall) {
    self.template = template
    self.subtype = subtype
  }

  private enum CodingKeys: CodingKey { case command, subtype }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let command = try container.decode(String.self, forKey: .command)
    self.subtype = try container.decode(Subtype.self, forKey: .subtype)

    guard let template = MathTemplate.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command,
        in: container, debugDescription: "Unknown command \(command)")
    }
    self.template = template.template
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(command, forKey: .command)
    try container.encode(subtype, forKey: .subtype)
  }
}

extension MathTemplate {
  func getApplyExpr() -> ApplyExpr {
    let count = template.parameterCount
    let arguments: [ContentExpr] = (0..<count).map { _ in ContentExpr() }
    return ApplyExpr(name, arguments: arguments)
  }
}

extension MathTemplate {
  static let allCommands: [MathTemplate] = [
    operatorname,
    pmod,
  ]

  private static let _dictionary: [String: MathTemplate] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathTemplate? {
    _dictionary[command]
  }

  static func lookup(_ tempalteName: TemplateName) -> MathTemplate? {
    lookup(tempalteName.identifier.name)
  }

  static let operatorname: MathTemplate = {
    let template = Template(
      name: "operatorname", parameters: ["content"],
      body: [
        MathKindExpr(
          .mathop,
          [
            MathVariantExpr(
              .mathrm,
              [
                VariableExpr("content")
              ])
          ])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled)
  }()

  static let pmod: MathTemplate = {
    let template = Template(
      name: "pmod", parameters: ["content"],
      body: [
        TextExpr("\u{2001}("),  // \quad (
        MathVariantExpr(.mathrm, [TextExpr("mod")]),
        TextExpr("\u{2004}"),  // thickspace
        VariableExpr("content"),
        TextExpr(")"),
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled)
  }()
}
