// Copyright 2024-2025 Lie Yan

public struct CommandRecord {
  public let name: String
  public let body: CommandBody

  init(_ symbol: SymbolMnemonic, _ category: ContentCategory) {
    self.name = symbol.command
    self.body = CommandBody(symbol, category)
  }

  init(_ symbol: MathSymbol, _ category: ContentCategory) {
    self.name = symbol.command
    self.body = CommandBody(symbol, category)
  }

  init(_ name: String, _ body: CommandBody) {
    self.name = name
    self.body = body
  }
}
