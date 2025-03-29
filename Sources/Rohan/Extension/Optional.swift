// Copyright 2024-2025 Lie Yan

import Foundation

extension Optional<Void> {
  func or_else(_ f: () -> Void) {
    if self == nil {
      f()
    }
  }
}
