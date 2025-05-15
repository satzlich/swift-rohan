// Copyright 2024-2025 Lie Yan

import Foundation

enum LoadResult<T, U> {
  /// Data is loaded successfully.
  case success(T)
  /// Data is loaded but has some issues.
  case corrupted(T)
  /// Unable to load data. U may be a fallback value.
  case failure(U)

  func unwrap() -> T where T == U {
    switch self {
    case .success(let value):
      return value
    case .corrupted(let value):
      return value
    case .failure(let value):
      return value
    }
  }

  var isSuccess: Bool {
    if case .success = self { return true }
    return false
  }

  var isFailure: Bool {
    if case .failure = self { return true }
    return false
  }

  func cast<V>() -> LoadResult<V, U> {
    switch self {
    case .success(let value):
      return .success(value as! V)
    case .corrupted(let value):
      return .corrupted(value as! V)
    case .failure(let value):
      return .failure(value)
    }
  }
}
