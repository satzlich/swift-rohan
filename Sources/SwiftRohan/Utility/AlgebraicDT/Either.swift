public enum Either<L, R> {
  case Left(L)
  case Right(R)

  // MARK: - Left and right.

  /// Convert ``Either<L, R>`` to `Either<R, L>`.
  @inlinable
  public func flip() -> Either<R, L> {
    switch self {
    case let .Left(l):
      .Right(l)
    case let .Right(r):
      .Left(r)
    }
  }

  /// Map `f` on the left, and `g` on the right.
  @inlinable
  public func map_either<U, V>(
    _ f: (L) throws -> U, _ g: (R) throws -> V
  ) rethrows -> Either<U, V> {
    switch self {
    case let .Left(l):
      try .Left(f(l))
    case let .Right(r):
      try .Right(g(r))
    }
  }

  // MARK: - L == R

  /// Map `f` on the left or right if `L == R`.
  @inlinable
  public func map<T>(_ f: (L) throws -> T) rethrows -> Either<T, T>
  where L == R {
    try map_either(f, f)
  }

  /// Unwrap `Either<L, R>` if `L == R`.
  @inlinable
  public func unwrap() -> R
  where L == R {
    switch self {
    case let .Left(l):
      l
    case let .Right(r):
      r
    }
  }

  // MARK: - Left or right only.

  @inlinable
  public func left() -> L? {
    switch self {
    case let .Left(l):
      l
    case .Right:
      nil
    }
  }

  @inlinable
  public func right() -> R? {
    switch self {
    case .Left:
      nil
    case let .Right(r):
      r
    }
  }

  @inlinable
  public func is_left() -> Bool {
    switch self {
    case .Left:
      true
    case .Right:
      false
    }
  }

  @inlinable
  public func is_right() -> Bool {
    switch self {
    case .Left:
      false
    case .Right:
      true
    }
  }

  /// Map left value.
  @inlinable
  public func map_left<U>(_ f: (L) throws -> U) rethrows -> Either<U, R> {
    switch self {
    case let .Left(l):
      try .Left(f(l))
    case let .Right(r):
      .Right(r)
    }
  }

  /// Map right value.
  @inlinable
  public func map_right<U>(_ f: (R) throws -> U) rethrows -> Either<L, U> {
    switch self {
    case let .Left(l):
      .Left(l)
    case let .Right(r):
      try .Right(f(r))
    }
  }

  /// Returns the left value
  /// - Precondition: this is a left value.
  @inlinable
  public func unwrap_left() -> L {
    switch self {
    case let .Left(l):
      l
    case .Right:
      preconditionFailure("Expected Left, got Right")
    }
  }

  /// Returns the right value
  /// - Precondition: this is a right value.
  @inlinable
  public func unwrap_right() -> R {
    switch self {
    case .Left:
      preconditionFailure("Expected Right, got Left")
    case let .Right(r):
      r
    }
  }
}

extension Either: Equatable
where L: Equatable, R: Equatable {}

extension Either: Hashable
where L: Hashable, R: Hashable {}
