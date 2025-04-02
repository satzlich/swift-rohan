// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import Numerics

extension CGPoint {
  /// Returns the relative position of this point with respect to reference point.
  @inlinable @inline(__always)
  public func relative(to reference: CGPoint) -> CGPoint {
    CGPoint(x: x - reference.x, y: y - reference.y)
  }

  @inlinable @inline(__always)
  public func translated(by delta: CGPoint) -> CGPoint {
    CGPoint(x: x + delta.x, y: y + delta.y)
  }

  @inlinable @inline(__always)
  public func with(xDelta: CGFloat) -> CGPoint {
    CGPoint(x: x + xDelta, y: y)
  }

  @inlinable @inline(__always)
  public func with(yDelta: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y + yDelta)
  }

  @inlinable @inline(__always)
  public func with(x: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y)
  }

  @inlinable @inline(__always)
  public func with(y: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y)
  }

  @inlinable @inline(__always)
  public func isNearlyEqual(to other: CGPoint) -> Bool {
    x.isApproximatelyEqual(to: other.x) && y.isApproximatelyEqual(to: other.y)
  }

  public func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let x = String(format: "%.\(precision)f", self.x)
    let y = String(format: "%.\(precision)f", self.y)
    return "(\(x), \(y))"
  }
}

extension CGSize {
  @inlinable @inline(__always)
  public func with(width: CGFloat) -> CGSize {
    CGSize(width: width, height: height)
  }

  @inlinable @inline(__always)
  public func with(height: CGFloat) -> CGSize {
    CGSize(width: width, height: height)
  }

  @inlinable @inline(__always)
  public func isNearlyEqual(to other: CGSize) -> Bool {
    width.isApproximatelyEqual(to: other.width)
      && height.isApproximatelyEqual(to: other.height)
  }

  public func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let width = String(format: "%.\(precision)f", self.width)
    let height = String(format: "%.\(precision)f", self.height)
    return "(\(width), \(height))"
  }
}

extension CGRect {
  @inlinable @inline(__always)
  public func isNearlyEqual(to other: CGRect) -> Bool {
    origin.isNearlyEqual(to: other.origin) && size.isNearlyEqual(to: other.size)
  }

  public func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let x = String(format: "%.\(precision)f", origin.x)
    let y = String(format: "%.\(precision)f", origin.y)
    let width = String(format: "%.\(precision)f", size.width)
    let height = String(format: "%.\(precision)f", size.height)
    return "(\(x), \(y), \(width), \(height))"
  }
}
