// Copyright 2024-2025 Lie Yan

import Foundation

enum LoadResult<T, U> {
  /// Data is loaded successfully.
  case success(T)
  /// Data is loaded but has some issues.
  case corrupted(T)
  /// Unable to load data.
  case unknown(U)

  func unwrap() -> T where T == U {
    switch self {
    case .success(let value):
      return value
    case .corrupted(let value):
      return value
    case .unknown(let value):
      return value
    }
  }

  var isSuccess: Bool {
    if case .success = self { return true }
    return false
  }
}
