// Copyright 2024-2025 Lie Yan

public struct CommandRecord {
  public let name: String
  public let body: CommandBody

  init(_ symbol: UniversalSymbol) {
    self.name = symbol.command
    self.body = CommandBody.from(symbol)
  }

  init(_ symbol: MathSymbol) {
    self.name = symbol.command
    self.body = CommandBody.from(symbol)
  }

  init(_ name: String, _ body: CommandBody) {
    self.name = name
    self.body = body
  }
}
