// Copyright 2024-2025 Lie Yan

import Foundation

extension Result {
  @inline(__always)
  var isSuccess: Bool {
    switch self {
    case .success: return true
    case .failure: return false
    }
  }

  @inline(__always)
  var isFailure: Bool {
    switch self {
    case .success: return false
    case .failure: return true
    }
  }

  @inline(__always)
  func success() -> Success? {
    switch self {
    case let .success(value): return value
    case .failure: return nil
    }
  }

  @inline(__always)
  func failure() -> Failure? {
    switch self {
    case .success: return nil
    case let .failure(error): return error
    }
  }
}
