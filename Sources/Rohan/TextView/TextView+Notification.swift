// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  func notifyOperationRejected() {
    self.window?.shake()
  }
}
