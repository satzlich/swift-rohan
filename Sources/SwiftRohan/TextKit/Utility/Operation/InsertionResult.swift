// Copyright 2024-2025 Lie Yan

enum InsertionResult<T> {
  /// insertion is successful.
  case inserted(T)
  /// insertion is successful with a new paragraph created holding the inserted content.
  case paragraphInserted(T)
  
  case failure(SatzError)

  func map<U>(_ transform: (T) throws -> U) rethrows -> InsertionResult<U> {
    switch self {
    case .inserted(let value):
      return .inserted(try transform(value))
    case .paragraphInserted(let value):
      return .paragraphInserted(try transform(value))
    case .failure(let error):
      return .failure(error)
    }
  }
}
