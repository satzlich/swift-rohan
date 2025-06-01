// Copyright 2024-2025 Lie Yan

import CoreGraphics

extension CGSize {
  @inline(__always)
  internal func with(width: CGFloat) -> CGSize {
    CGSize(width: width, height: height)
  }

  @inline(__always)
  internal func with(height: CGFloat) -> CGSize {
    CGSize(width: width, height: height)
  }

  @inline(__always)
  internal func isNearlyEqual(to other: CGSize) -> Bool {
    width.isApproximatelyEqual(to: other.width)
      && height.isApproximatelyEqual(to: other.height)
  }

  internal func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let width = String(format: "%.\(precision)f", self.width)
    let height = String(format: "%.\(precision)f", self.height)
    return "(\(width), \(height))"
  }
}
