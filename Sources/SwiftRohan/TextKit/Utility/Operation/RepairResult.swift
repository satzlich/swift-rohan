enum RepairResult<T>: Equatable, Hashable where T: Equatable & Hashable {
  case original(T)
  case repaired(T)
  case failure

  func unwrap() -> T? {
    switch self {
    case let .original(value): return value
    case let .repaired(value): return value
    case .failure: return nil
    }
  }
}
