// Copyright 2024-2025 Lie Yan

struct SymbolMnemonic {
  let command: String
  let unicode: String

  init(_ command: String, _ unicode: String) {
    self.command = command
    self.unicode = unicode
  }

  func toCommandRecord(_ category: ContentCategory) -> CommandRecord {
    CommandRecord(command, category, [TextExpr(unicode)])
  }
}
