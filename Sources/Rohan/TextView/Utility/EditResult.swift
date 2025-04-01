// Copyright 2024-2025 Lie Yan

import Foundation

enum EditResult {
  case success
  case rejected(Error)
  case internalError(Error)

  var isSuccess: Bool {
    if case .success = self { return true }
    return false
  }

  var isRejected: Bool {
    if case .rejected = self { return true }
    return false
  }

  var isInternalError: Bool {
    if case .internalError = self { return true }
    return false
  }

  func internalError() -> Error? {
    if case let .internalError(error) = self { return error }
    return nil
  }
}
