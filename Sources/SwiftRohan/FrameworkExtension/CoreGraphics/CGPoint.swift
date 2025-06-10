// Copyright 2024-2025 Lie Yan

import CoreGraphics

extension CGPoint {
  @inline(__always)
  internal func relative(to reference: CGPoint) -> CGPoint {
    CGPoint(x: x - reference.x, y: y - reference.y)
  }

  @inline(__always)
  internal func translated(by delta: CGPoint) -> CGPoint {
    CGPoint(x: x + delta.x, y: y + delta.y)
  }

  @inline(__always)
  internal func with(xDelta: CGFloat) -> CGPoint {
    CGPoint(x: x + xDelta, y: y)
  }

  @inline(__always)
  internal func with(yDelta: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y + yDelta)
  }

  @inline(__always)
  internal func with(x: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y)
  }

  @inline(__always)
  internal func with(y: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y)
  }

  @inline(__always)
  internal func isNearlyEqual(to other: CGPoint) -> Bool {
    x.isNearlyEqual(to: other.x) && y.isNearlyEqual(to: other.y)
  }

  internal func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let x = String(format: "%.\(precision)f", self.x)
    let y = String(format: "%.\(precision)f", self.y)
    return "(\(x), \(y))"
  }
}
