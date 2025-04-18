// Copyright 2024-2025 Lie Yan

enum RepairResult<T>: Equatable, Hashable where T: Equatable & Hashable {
  case original(T)
  case repaired(T)
  case failure

  func unwrap() -> T? {
    switch self {
    case let .original(value):
      return value
    case let .repaired(value):
      return value
    case .failure:
      return nil
    }
  }

  func map<U>(_ transform: (T) -> U) -> RepairResult<U> {
    switch self {
    case let .original(value):
      return .original(transform(value))
    case let .repaired(value):
      return .repaired(transform(value))
    case .failure:
      return .failure
    }
  }
}
