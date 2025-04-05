// Copyright 2024-2025 Lie Yan

public struct CommandRecord {
  /// The name of the command.
  public let command: String

  /// The category of the content produced by this command.
  public let contentCategory: ContentCategory

  /// Returns the content for this command.
  public func createContent() -> [Node] {
    []
  }
}
