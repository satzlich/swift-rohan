// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  /// Notify user that the operation is rejected.
  func notifyOperationIsRejected() {
    self.window?.shake()
  }
}
