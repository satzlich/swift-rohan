// Copyright 2024-2025 Lie Yan

enum OneOrPair<U, V> {
  case left(U)
  case right(V)
  case pair(U, V)

  var isLeft: Bool {
    if case .left = self { return true }
    return false
  }
  var isRight: Bool {
    if case .right = self { return true }
    return false
  }
  var isBoth: Bool {
    if case .pair = self { return true }
    return false
  }

  func left() -> U? {
    if case let .left(value) = self { return value }
    return nil
  }

  func right() -> V? {
    if case let .right(value) = self { return value }
    return nil
  }

  func both() -> (U, V)? {
    if case let .pair(left, right) = self { return (left, right) }
    return nil
  }
}
