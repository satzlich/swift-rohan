// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import Numerics

extension CGRect {

  /// Returns a rectangle with an origin that is offset from that of the source rectangle.
  @inline(__always)
  internal func offsetBy(_ delta: CGPoint) -> CGRect {
    self.offsetBy(dx: delta.x, dy: delta.y)
  }

  @inline(__always)
  internal func isNearlyEqual(to other: CGRect) -> Bool {
    origin.isNearlyEqual(to: other.origin) && size.isNearlyEqual(to: other.size)
  }

  internal func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let x = String(format: "%.\(precision)f", origin.x)
    let y = String(format: "%.\(precision)f", origin.y)
    let width = String(format: "%.\(precision)f", size.width)
    let height = String(format: "%.\(precision)f", size.height)
    return "(\(x), \(y), \(width), \(height))"
  }
}
