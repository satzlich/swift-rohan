import Foundation

enum LoadResult<T, U> {
  /// Data is loaded successfully.
  case success(T)
  /// Data is loaded but has some issues.
  case corrupted(T)
  /// Unable to load data. U may be a fallback value.
  case failure(U)

  func unwrap() -> T {
    switch self {
    case .success(let value):
      return value
    case .corrupted(let value):
      return value
    case .failure(let value):
      return value as! T
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

}

extension LoadResult where T: Node, U: Node {
  @inline(__always)
  internal func cast() -> LoadResult<Node, U> {
    switch self {
    case .success(let value):
      return .success(value)
    case .corrupted(let value):
      return .corrupted(value)
    case .failure(let value):
      return .failure(value)
    }
  }
}

extension LoadResult where T: ContentNode, U: Node {
  @inline(__always)
  internal func cast() -> LoadResult<ContentNode, U> {
    switch self {
    case .success(let value):
      return .success(value)
    case .corrupted(let value):
      return .corrupted(value)
    case .failure(let value):
      return .failure(value)
    }
  }
}
