// Copyright 2024-2025 Lie Yan

enum EditResult<T> {
  /// insertion is successful, no special handling is required.
  case success(T)
  /// insertion is successful with a new paragraph created holding the inserted content.
  case extraParagraph(T)
  /// insertion of block nodes is successful.
  case blockInserted(T)

  case failure(SatzError)

  func map<U>(_ transform: (T) throws -> U) rethrows -> EditResult<U> {
    switch self {
    case .success(let value):
      return .success(try transform(value))
    case .extraParagraph(let value):
      return .extraParagraph(try transform(value))
    case .blockInserted(let value):
      return .blockInserted(try transform(value))
    case .failure(let error):
      return .failure(error)
    }
  }

  var isSuccess: Bool {
    switch self {
    case .success: return true
    case .extraParagraph: return true
    case .blockInserted: return true
    case .failure: return false
    }
  }

  var isFailure: Bool {
    return !isSuccess
  }

  func success() -> T? {
    switch self {
    case .success(let value): return value
    case .extraParagraph(let value): return value
    case .blockInserted(let value): return value
    case .failure: return nil
    }
  }

  func failure() -> SatzError? {
    switch self {
    case .failure(let error):
      return error
    default:
      return nil
    }
  }

  var isInternalError: Bool {
    switch self {
    case .failure(let error):
      return error.code.type == .InternalError
    default:
      return false
    }
  }
}
