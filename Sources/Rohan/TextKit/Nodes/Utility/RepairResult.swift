// Copyright 2024-2025 Lie Yan

enum RepairResult<T>: Equatable, Hashable
where T: Equatable & Hashable {
  case original(T)
  case repaired(T)
  case unrepairable
}
