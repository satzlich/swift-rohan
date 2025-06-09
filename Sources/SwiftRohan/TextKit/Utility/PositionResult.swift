// Copyright 2024-2025 Lie Yan

/// Result of locating with layout offset.

public enum PositionResult<T> {
  /// a terminal value with a target offset, that is, no further traversal is possible.
  case terminal(value: T, target: Int)
  /// a halfway value with the offset consumed so far.
  case halfway(value: T, consumed: Int)
  /// no suitable value was found but no error was raised.
  case null
  /// a failure with an error.
  case failure(SatzError)

  var isTerminal: Bool {
    if case .terminal = self { return true }
    return false
  }
  var isHalfway: Bool {
    if case .halfway = self { return true }
    return false
  }
  var isFailure: Bool {
    if case .failure = self { return true }
    return false
  }

  var value: T? {
    switch self {
    case let .terminal(value, _): return value
    case let .halfway(value, _): return value
    case .null: return nil
    case .failure: return nil
    }
  }

  var offset: Int? {
    switch self {
    case let .terminal(_, target): return target
    case let .halfway(_, consumed): return consumed
    case .null: return nil
    case .failure: return nil
    }
  }
}
