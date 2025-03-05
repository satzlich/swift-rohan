// Copyright 2024-2025 Lie Yan

enum RepairResult<T>: Equatable, Hashable
where T: Equatable & Hashable {
  case original(T)
  case repaired(T)
  case unrepairable

  func unwrap() -> T? {
    switch self {
    case let .original(value):
      return value
    case let .repaired(value):
      return value
    case .unrepairable:
      return nil
    }
  }
}
