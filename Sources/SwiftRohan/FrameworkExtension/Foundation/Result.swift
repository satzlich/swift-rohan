import Foundation

extension Result {
  @inlinable @inline(__always)
  var isSuccess: Bool {
    switch self {
    case .success: return true
    case .failure: return false
    }
  }

  @inlinable @inline(__always)
  var isFailure: Bool {
    switch self {
    case .success: return false
    case .failure: return true
    }
  }

  @inlinable @inline(__always)
  func success() -> Success? {
    switch self {
    case let .success(value): return value
    case .failure: return nil
    }
  }

  @inlinable @inline(__always)
  func failure() -> Failure? {
    switch self {
    case .success: return nil
    case let .failure(error): return error
    }
  }
}
