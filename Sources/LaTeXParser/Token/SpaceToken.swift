// Copyright 2024-2025 Lie Yan

/// Consecutive spaces.
public struct SpaceToken: Token {
  public let count: Int

  public init(count: Int) {
    precondition(count > 0)
    self.count = count
  }
}
