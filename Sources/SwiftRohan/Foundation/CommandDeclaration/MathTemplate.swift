// Copyright 2024-2025 Lie Yan

import Foundation

struct MathTemplate: CommandDeclarationProtocol {
  enum Subtype: String, Codable {
    /// For command, a call to the template is output for storage.
    case command
    /// For code snippet, the expanded content is output for storage.
    case snippet
  }

  var command: String { template.name.identifier.name }
  let template: CompiledTemplate
  let subtype: Subtype

  init(subtype: Subtype = .command, _ template: CompiledTemplate) {
    self.template = template
    self.subtype = subtype
  }
}

extension MathTemplate {
  static let predefinedCases: [MathTemplate] = [
    operatorname
  ]

  private static let _dictionary: [String: MathTemplate] =
    Dictionary(uniqueKeysWithValues: predefinedCases.map { ($0.command, $0) })

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
