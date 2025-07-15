// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

struct MathTemplate: CommandDeclarationProtocol {
  enum Subtype: String, Codable {
    /// For command call, the template is used to create a command call.
    case commandCall
    /// For environment use, the template is used to create an environment.
    case environmentUse
    /// For code snippet, the expanded content is output for storage.
    case codeSnippet
  }

  var command: String { template.name.identifier.name }
  var tag: CommandTag { .null }
  var source: CommandSource { .preBuilt }

  let template: CompiledTemplate
  let subtype: Subtype
  let layoutType: LayoutType

  var name: TemplateName { template.name }
  var parameterCount: Int { template.parameterCount }

  init(_ template: CompiledTemplate, _ subtype: Subtype, _ layoutType: LayoutType) {
    self.template = template
    self.subtype = subtype
    self.layoutType = layoutType
  }

  private enum CodingKeys: CodingKey { case command, subtype, layoutType }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let command = try container.decode(String.self, forKey: .command)
    guard let template = MathTemplate.lookup(command) else {
      throw DecodingError.dataCorruptedError(
        forKey: .command,
        in: container, debugDescription: "Unknown command \(command)")
    }
    self.template = template.template
    self.subtype = template.subtype
    self.layoutType = template.layoutType
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(command, forKey: .command)
  }
}

extension MathTemplate {
  nonisolated(unsafe) static let allCommands: Array<MathTemplate> = [
    operatorname,
    overset,
    pmod,
    stackrel,
    underset,
    theorem,
    proof,
  ]

  nonisolated(unsafe) private static let _dictionary: Dictionary<String, MathTemplate> =
    Dictionary(uniqueKeysWithValues: allCommands.map { ($0.command, $0) })

  static func lookup(_ command: String) -> MathTemplate? {
    _dictionary[command]
  }

  static func lookup(_ tempalteName: TemplateName) -> MathTemplate? {
    lookup(tempalteName.identifier.name)
  }

  nonisolated(unsafe) static let operatorname: MathTemplate = {
    let template = Template(
      name: "operatorname", parameters: ["content"],
      body: [
        MathAttributesExpr(
          .mathKind(.mathop), [MathStylesExpr(.mathrm, [VariableExpr("content")])])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled, .commandCall, .inline)
  }()

  nonisolated(unsafe) static let overset: MathTemplate = {
    let template = Template(
      name: "overset", parameters: ["top", "content"],
      body: [
        AttachExpr(
          nuc: [MathAttributesExpr(.mathLimits(.limits), [VariableExpr("content")])],
          sup: [VariableExpr("top")])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled, .commandCall, .inline)
  }()

  nonisolated(unsafe) static let pmod: MathTemplate = {
    let template = Template(
      name: "pmod", parameters: ["content"],
      body: [
        TextExpr("\u{2001}("),  // \quad (
        MathStylesExpr(.mathrm, [TextExpr("mod")]),
        TextExpr("\u{2004}"),  // thickspace
        VariableExpr("content"),
        TextExpr(")"),
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled, .commandCall, .inline)
  }()

  nonisolated(unsafe) static let stackrel: MathTemplate = {
    let template = Template(
      name: "stackrel", parameters: ["top", "bottom"],
      body: [
        AttachExpr(
          nuc: [MathAttributesExpr(.combo(.mathrel, .limits), [VariableExpr("bottom")])],
          sup: [VariableExpr("top")])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled, .commandCall, .inline)
  }()

  nonisolated(unsafe) static let underset: MathTemplate = {
    let template = Template(
      name: "underset", parameters: ["bottom", "content"],
      body: [
        AttachExpr(
          nuc: [MathAttributesExpr(.mathLimits(.limits), [VariableExpr("content")])],
          sub: [VariableExpr("bottom")])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled, .commandCall, .inline)
  }()

  nonisolated(unsafe) static let theorem: MathTemplate =
    _createTheoremEnvironment(name: "theorem", title: "Theorem")

  nonisolated(unsafe) static let proof: MathTemplate = {
    let template = Template(
      name: "proof", parameters: ["content"],
      body: [
        ParListExpr([
          TextStylesExpr(
            .textit,
            [
              TextExpr("Proof. ")
            ]),
          VariableExpr("content"),
        ])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled, .environmentUse, .block)
  }()

  static func _createTheoremEnvironment(name: String, title: String) -> MathTemplate {
    let template = Template(
      name: name, parameters: ["content"],
      body: [
        ParListExpr([
          TextStylesExpr(
            .textbf,
            [
              TextExpr("\(title) "),
              CounterExpr(.theorem),
              TextExpr(" "),
            ]),
          VariableExpr("content"),
        ])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled, .environmentUse, .block)
  }
}
