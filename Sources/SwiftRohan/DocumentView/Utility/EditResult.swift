// Copyright 2024-2025 Lie Yan

import Foundation

enum EditResult {
  case success(RhTextRange)
  case userError(Error)
  case internalError(Error)

  var isInternalError: Bool {
    if case .internalError = self { return true }
    return false
  }

  func success() -> RhTextRange? {
    if case let .success(range) = self { return range }
    return nil
  }
}
