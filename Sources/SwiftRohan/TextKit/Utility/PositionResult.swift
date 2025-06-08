// Copyright 2024-2025 Lie Yan

/// Result of locating with layout offset.

public enum PositionResult<T> {
  case success(value: T, target: Int)
  case halfway(value: T, consumed: Int)
  case null
  case failure(error: SatzError)

  var value: T? {
    switch self {
    case let .success(value, _): return value
    case let .halfway(value, _): return value
    case .null: return nil
    case .failure: return nil
    }
  }

  var offset: Int? {
    switch self {
    case let .success(_, target): return target
    case let .halfway(_, consumed): return consumed
    case .null: return nil
    case .failure: return nil
    }
  }
}
