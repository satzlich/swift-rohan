// Copyright 2024-2025 Lie Yan

struct UniversalSymbol: Codable, CommandDeclarationProtocol {
  enum Subtype: String, Codable {
    case math
    case text
    case universal
  }

  let command: String
  let string: String

  init(_ command: String, _ string: String) {
    self.command = command
    self.string = string
  }
}

extension UniversalSymbol {
  static let predefinedCases: [UniversalSymbol] = [
    .init("P", "\u{00B6}"),  // ¶
    .init("S", "\u{00A7}"),  // §
    .init("dag", "\u{2020}"),  // †
    .init("ddag", "\u{2021}"),  // ‡
  ]
}
