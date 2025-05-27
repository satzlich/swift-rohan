// Copyright 2024-2025 Lie Yan

/// Consecutive spaces.
public struct SpaceToken: TokenProtocol {
  public let count: Int

  public init(count: Int = 1) {
    precondition(count > 0)
    self.count = count
  }
}
