// Copyright 2024-2025 Lie Yan

import Foundation

struct MathTemplate: CommandDeclarationProtocol {
  var command: String { template.name.identifier.name }
  let template: CompiledTemplate

  init(_ template: CompiledTemplate) {
    self.template = template
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
