// Copyright 2024-2025 Lie Yan

import Foundation

enum EditResult {
  case success(RhTextRange)
  case operationRejected(Error)
  case internalError(Error)

  var isInternalError: Bool {
    if case .internalError = self { return true }
    return false
  }
  
  var isOperationRejected: Bool {
    if case .operationRejected = self { return true }
    return false
  }
  
  func internalError() -> Error? {
    if case let .internalError(error) = self { return error }
    return nil
  }
}
