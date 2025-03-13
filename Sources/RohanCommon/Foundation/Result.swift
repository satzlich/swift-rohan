// Copyright 2024-2025 Lie Yan

import Foundation

extension Result {
  @inlinable
  public var isSuccess: Bool {
    switch self {
    case .success: return true
    case .failure: return false
    }
  }

  @inlinable
  public var isFailure: Bool {
    switch self {
    case .success: return false
    case .failure: return true
    }
  }

  @inlinable
  public func success() -> Success? {
    switch self {
    case let .success(value): return value
    case .failure: return nil
    }
  }

  @inlinable
  public func failure() -> Failure? {
    switch self {
    case .success: return nil
    case let .failure(error): return error
    }
  }
}
