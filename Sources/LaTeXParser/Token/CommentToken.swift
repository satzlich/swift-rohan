// Copyright 2024-2025 Lie Yan

public struct CommentToken: TokenProtocol {
  public var commentChar: Character { "%" }
  public let content: String

  public init(_ content: String) {
    self.content = content
  }
}
