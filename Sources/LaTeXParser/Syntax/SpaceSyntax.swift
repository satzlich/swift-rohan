// Copyright 2024-2025 Lie Yan

/// Consecutive spaces.
public struct SpaceSyntax: Syntax {
  public let count: Int

  public init(count: Int) {
    precondition(count > 0)
    self.count = count
  }
}
