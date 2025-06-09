// Copyright 2024-2025 Lie Yan

///// Result of a replacement operation in text processing.
//enum ReplaceResult<T> {
//  /// Replacement is successful.
//  case inserted(T)
//  /// Replacement is successful with a new paragraph created holding the replacement.
//  case paragraphInserted(T)
//
//  case failure(SatzError)
//
//  func map<U>(_ transform: (T) throws -> U) rethrows -> ReplaceResult<U> {
//    switch self {
//    case .inserted(let value):
//      return .inserted(try transform(value))
//    case .paragraphInserted(let value):
//      return .paragraphInserted(try transform(value))
//    case .failure(let error):
//      return .failure(error)
//    }
//  }
//
//  var isSuccess: Bool {
//    switch self {
//    case .inserted, .paragraphInserted:
//      return true
//    case .failure:
//      return false
//    }
//  }
//
//  var isFailure: Bool {
//    return !isSuccess
//  }
//
//  func success() -> T? {
//    switch self {
//    case .inserted(let value):
//      return value
//    case .paragraphInserted(let value):
//      return value
//    case .failure:
//      return nil
//    }
//  }
//
//  func failure() -> SatzError? {
//    switch self {
//    case .failure(let error):
//      return error
//    default:
//      return nil
//    }
//  }
//}
//
//extension ReplaceResult {
//  var isInternalError: Bool {
//    switch self {
//    case .failure(let error):
//      return error.code.type == .InternalError
//    default:
//      return false
//    }
//  }
//}
