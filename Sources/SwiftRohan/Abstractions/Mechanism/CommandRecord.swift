public struct CommandRecord {
  public let name: String
  public let body: CommandBody

  init(_ symbol: NamedSymbol) {
    self.name = symbol.command
    self.body = CommandBody.namedSymbolExpr(symbol)
  }

  init(_ name: String, _ body: CommandBody) {
    self.name = name
    self.body = body
  }
}
