// Copyright 2024-2025 Lie Yan

struct CommandRecord {
  /// The name of the command.
  public let command: String

  /// The content produced by this command.
  public let content: [Expr]

  /// The category of the content produced by this command.
  public let contentCategory: ContentCategory
}
