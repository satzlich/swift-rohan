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
  static let allCommands: [MathTemplate] = [
    operatorname
  ]

  private static let _dictionary: [String: MathTemplate] =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathTemplate? {
    _dictionary[command]
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
}
