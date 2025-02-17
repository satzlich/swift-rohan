// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import Numerics

extension CGPoint {
  public func clamped(to rect: CGRect) -> CGPoint {
    CGPoint(
      x: x.clamped(rect.minX, rect.maxX),
      y: y.clamped(rect.minY, rect.maxY))
  }

  /** Returns the relative position of this one with respect to reference */
  public func relative(to reference: CGPoint) -> CGPoint {
    CGPoint(x: x - reference.x, y: y - reference.y)
  }

  @inline(__always)
  public func translated(by delta: CGPoint) -> CGPoint {
    CGPoint(x: x + delta.x, y: y + delta.y)
  }

  @inline(__always)
  public func with(yDelta: CGFloat) -> CGPoint {
    CGPoint(x: x, y: y + yDelta)
  }

  @inline(__always)
  public func with(xDelta: CGFloat) -> CGPoint {
    CGPoint(x: x + xDelta, y: y)
  }

  public static prefix func - (_ point: CGPoint) -> CGPoint {
    CGPoint(x: -point.x, y: -point.y)
  }

  public func isApproximatelyEqual(to other: CGPoint) -> Bool {
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
  public func isApproximatelyEqual(to other: CGSize) -> Bool {
    width.isApproximatelyEqual(to: other.width) && height.isApproximatelyEqual(to: other.height)
  }

  public func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let width = String(format: "%.\(precision)f", self.width)
    let height = String(format: "%.\(precision)f", self.height)
    return "(\(width), \(height))"
  }
}

extension CGRect {
  public func isApproximatelyEqual(to other: CGRect) -> Bool {
    origin.isApproximatelyEqual(to: other.origin) && size.isApproximatelyEqual(to: other.size)
  }

  public func formated(_ precision: Int) -> String {
    precondition(precision >= 0)
    let x = String(format: "%.\(precision)f", origin.x)
    let y = String(format: "%.\(precision)f", origin.y)
    let width = String(format: "%.\(precision)f", size.width)
    let height = String(format: "%.\(precision)f", size.height)
    return "(\(x), \(y), \(width), \(height))"
  }
}
