// Copyright 2024-2025 Lie Yan

/// Either or both.
enum EitherBoth<L, R> {
  case left(L)
  case right(R)
  case pair(L, R)

  var isLeft: Bool {
    if case .left = self { return true }
    return false
  }
  var isRight: Bool {
    if case .right = self { return true }
    return false
  }
  var isPair: Bool {
    if case .pair = self { return true }
    return false
  }

  func left() -> L? {
    if case let .left(value) = self { return value }
    return nil
  }

  func right() -> R? {
    if case let .right(value) = self { return value }
    return nil
  }

  func pair() -> (L, R)? {
    if case let .pair(left, right) = self { return (left, right) }
    return nil
  }
}
