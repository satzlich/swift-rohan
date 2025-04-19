// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  /// Notify user that the operation is rejected.
  func notifyOperationRejected() {
    self.window?.shake()
  }
}
