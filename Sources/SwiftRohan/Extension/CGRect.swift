// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation

extension CGRect {
  /// Returns a rectangle with an origin that is offset from that of the source rectangle.
  @inline(__always)
  func offsetBy(_ delta: CGPoint) -> CGRect {
    self.offsetBy(dx: delta.x, dy: delta.y)
  }
}
