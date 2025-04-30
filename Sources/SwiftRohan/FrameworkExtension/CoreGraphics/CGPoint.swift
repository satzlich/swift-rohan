// Copyright 2024-2025 Lie Yan

import CoreGraphics

extension CGPoint {
  @inline(__always)
  func relative(to reference: CGPoint) -> CGPoint {
    CGPoint(x: x - reference.x, y: y - reference.y)
  }

  @inline(__always)
  func translated(by delta: CGPoint) -> CGPoint {
    CGPoint(x: x + delta.x, y: y + delta.y)
  }

  @inline(__always)
  func with(xDelta: CGFloat) -> CGPoint {
    CGPoint(x: x + xDelta, y: y)
  }

  @inline(__always)
  func with(yDelta: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y + yDelta)
  }

  @inline(__always)
  func with(x: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y)
  }

  @inline(__always)
  func with(y: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y)
  }

  @inline(__always)
  func isNearlyEqual(to other: CGPoint) -> Bool {
    x.isApproximatelyEqual(to: other.x) && y.isApproximatelyEqual(to: other.y)
  }

  func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let x = String(format: "%.\(precision)f", self.x)
    let y = String(format: "%.\(precision)f", self.y)
    return "(\(x), \(y))"
  }
}
