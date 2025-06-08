// Copyright 2024-2025 Lie Yan

/// Result of locating with layout offset.

public enum PositionResult<T> {
  /// a terminal value with a target offset.
  case terminal(value: T, target: Int)
  /// a halfway value with the offset consumed so far.
  case halfway(value: T, consumed: Int)
  /// no suitable value was found but no error was raised.
  case null
  /// a failure with an error.
  case failure(error: SatzError)

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
