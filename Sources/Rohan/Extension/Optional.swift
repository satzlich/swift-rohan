// Copyright 2024-2025 Lie Yan

import Foundation

extension Optional<Void> {
  /// Execute the closure if the optional is nil.
  @inline(__always)
  func or_else(_ f: () -> Void) {
    if self == nil { f() }
  }
}
