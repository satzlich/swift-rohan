// Copyright 2024-2025 Lie Yan

/// Result of locating with layout offset.

public struct LocateResult<T> {
  enum State {
    case success(location: Int)
    case halfway(consumed: Int)
  }
  let value: T
}
