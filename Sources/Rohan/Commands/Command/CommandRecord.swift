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

  /// True if relocation of insertion point is required after insertion.
  let relocationRequired: Bool

  init(
    _ name: String, _ contentCategory: ContentCategory, _ content: [Expr],
    _ relocationRequired: Bool
  ) {
    self.name = name
    self.contentCategory = contentCategory
    self.content = .other(content)
    self.relocationRequired = relocationRequired
  }

  init(_ symbol: SymbolMnemonic, _ contentCategory: ContentCategory) {
    self.name = symbol.command
    self.contentCategory = contentCategory
    self.content = .plaintext(symbol.string)
    self.relocationRequired = false
  }
}
