// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import Numerics

extension CGRect {

  /// Returns a rectangle with an origin that is offset from that of the source rectangle.
  @inline(__always)
  func offsetBy(_ delta: CGPoint) -> CGRect {
    self.offsetBy(dx: delta.x, dy: delta.y)
  }

  @inline(__always)
  func isNearlyEqual(to other: CGRect) -> Bool {
    origin.isNearlyEqual(to: other.origin) && size.isNearlyEqual(to: other.size)
  }

  func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let x = String(format: "%.\(precision)f", origin.x)
    let y = String(format: "%.\(precision)f", origin.y)
    let width = String(format: "%.\(precision)f", size.width)
    let height = String(format: "%.\(precision)f", size.height)
    return "(\(x), \(y), \(width), \(height))"
  }
}

extension CGSize {
  @inline(__always)
  func with(width: CGFloat) -> CGSize {
    CGSize(width: width, height: height)
  }

  @inline(__always)
  func with(height: CGFloat) -> CGSize {
    CGSize(width: width, height: height)
  }

  @inline(__always)
  func isNearlyEqual(to other: CGSize) -> Bool {
    width.isApproximatelyEqual(to: other.width)
      && height.isApproximatelyEqual(to: other.height)
  }

  func formatted(_ precision: Int) -> String {
    precondition(precision >= 0)
    let width = String(format: "%.\(precision)f", self.width)
    let height = String(format: "%.\(precision)f", self.height)
    return "(\(width), \(height))"
  }
}

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
