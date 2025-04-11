// Copyright 2024-2025 Lie Yan

struct CommandRecord {
  /// The name of the command.
  public let name: String

  /// The category of the content produced by this command.
  public let contentCategory: ContentCategory

  /// The content produced by this command.
  public let content: [Expr]

  init(_ name: String, _ contentCategory: ContentCategory, _ content: [Expr]) {
    self.name = name
    self.contentCategory = contentCategory
    self.content = content
  }
}
