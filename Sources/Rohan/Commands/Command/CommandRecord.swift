// Copyright 2024-2025 Lie Yan

public struct CommandRecord {
  enum Content {
    case plaintext(String)
    case other([Expr])
  }

  /// The name of the command.
  public let name: String

  /// The category of the content produced by this command.
  let contentCategory: ContentCategory

  /// The content produced by this command.
  let content: Content

  /// Backward moves needed to relocate the cursor.
  let backwardMoves: Int

  init(
    _ name: String, _ contentCategory: ContentCategory, _ content: [Expr],
    _ backwardMoves: Int = 0
  ) {
    precondition(backwardMoves >= 0)
    self.name = name
    self.contentCategory = contentCategory
    self.content = .other(content)
    self.backwardMoves = backwardMoves
  }

  init(_ symbol: SymbolMnemonic, _ contentCategory: ContentCategory) {
    self.name = symbol.command
    self.contentCategory = contentCategory
    self.content = .plaintext(symbol.string)
    self.backwardMoves = 0
  }
}
