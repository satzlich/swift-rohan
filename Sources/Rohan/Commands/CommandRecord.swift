// Copyright 2024-2025 Lie Yan

struct CommandRecord {
  /// The name of the command.
  public let command: String

  /// The category of the content produced by this command.
  public let contentCategory: ContentCategory

  /// The content produced by this command.
  public let content: [Expr]

  init(_ command: String, _ contentCategory: ContentCategory, _ content: [Expr]) {
    self.command = command
    self.contentCategory = contentCategory
    self.content = content
  }
}
