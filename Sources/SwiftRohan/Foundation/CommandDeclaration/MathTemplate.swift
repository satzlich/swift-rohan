// Copyright 2024-2025 Lie Yan

import Foundation
import LatexParser

struct MathTemplate: CommandDeclarationProtocol {
  enum Subtype: String, Codable {
    /// For function call, a call to the template is output for storage.
    case functionCall
    /// For code snippet, the expanded content is output for storage.
    case codeSnippet
  }

  var command: String { template.name.identifier.name }
  var genre: CommandGenre { .other }
  var source: CommandSource { .preBuilt }

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
  static let allCommands: [MathTemplate] = [
    operatorname,
    overset,
    pmod,
    stackrel,
    underset,
    xleftarrow,
    xrightarrow,
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
        MathAttributesExpr(
          .mathKind(.mathop), [MathStylesExpr(.mathrm, [VariableExpr("content")])])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled)
  }()

  static let overset: MathTemplate = {
    let template = Template(
      name: "overset", parameters: ["top", "content"],
      body: [
        AttachExpr(
          nuc: [MathAttributesExpr(.mathLimits(._limits), [VariableExpr("content")])],
          sup: [VariableExpr("top")])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled)
  }()

  static let pmod: MathTemplate = {
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
    return MathTemplate(compiled)
  }()

  static let stackrel: MathTemplate = {
    let template = Template(
      name: "stackrel", parameters: ["top", "bottom"],
      body: [
        AttachExpr(
          nuc: [MathAttributesExpr(.combo(.mathrel, ._limits), [VariableExpr("bottom")])],
          sup: [VariableExpr("top")])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled)
  }()

  static let underset: MathTemplate = {
    let template = Template(
      name: "underset", parameters: ["bottom", "content"],
      body: [
        AttachExpr(
          nuc: [MathAttributesExpr(.mathLimits(._limits), [VariableExpr("content")])],
          sub: [VariableExpr("bottom")])
      ])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled)
  }()

  static let xleftarrow: MathTemplate = {
    let template = Template(
      name: "xleftarrow", parameters: ["content"],
      body: [AttachExpr(nuc: [TextExpr("\u{27F5}")], sup: [VariableExpr("content")])])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled)
  }()

  static let xrightarrow: MathTemplate = {
    let template = Template(
      name: "xrightarrow", parameters: ["content"],
      body: [AttachExpr(nuc: [TextExpr("\u{27F6}")], sup: [VariableExpr("content")])])
    let compiled = Nano.compile(template).success()!
    return MathTemplate(compiled)
  }()
}
