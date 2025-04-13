// Copyright 2024-2025 Lie Yan

struct SymbolMnemonic {
  /// The mnemonic command.
  let command: String
  /// The symbol string.
  let string: String

  init(_ command: String, _ string: String) {
    self.command = command
    self.string = string
  }
}
