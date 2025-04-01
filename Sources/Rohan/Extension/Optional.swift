// Copyright 2024-2025 Lie Yan

import Foundation

extension Optional {
  /// Execute the closure if the optional is nil.
  @inline(__always)
  func or_else(_ f: () -> Void) {
    if self == nil { f() }
  }

  /// Execute the closure if the optional is not nil.
  @inline(__always)
  func and_then(_ f: (Wrapped) -> Void) {
    if let x = self { f(x) }
  }
}
