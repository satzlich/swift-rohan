// Copyright 2024-2025 Lie Yan

struct TextSymbol {
  /// Mnemonic command
  let command: String
  let char: Character

  init(_ command: String, _ char: Character) {
    self.command = command
    self.char = char
  }
}

extension TextSymbol {
  static let predefinedCases: [TextSymbol] = [
    .init("P", "\u{00B6}"),  // ¶
    .init("S", "\u{00A7}"),  // §
    .init("dag", "\u{2020}"),  // †
    .init("ddag", "\u{2021}"),  // ‡
  ]
}
