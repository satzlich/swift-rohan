// Copyright 2024-2025 Lie Yan

public struct CommandRecord {
  public let name: String
  public let body: CommandBody

  init(
    _ name: String,
    _ exprs: [Expr],
    _ category: ContentCategory,
    _ backwardMoves: Int
  ) {
    precondition(backwardMoves >= 0)
    self.name = name
    self.body = CommandBody(exprs, category, backwardMoves)
  }

  init(_ symbol: SymbolMnemonic, _ category: ContentCategory) {
    self.name = symbol.command
    self.body = CommandBody(symbol, category)
  }

  init(_ name: String, _ body: CommandBody) {
    self.name = name
    self.body = body
  }
}
