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
  public func positionRelative(to reference: CGPoint) -> CGPoint {
    CGPoint(x: x - reference.x, y: y - reference.y)
  }

  public static prefix func - (_ point: CGPoint) -> CGPoint {
    CGPoint(x: -point.x, y: -point.y)
  }

  public func isApproximatelyEqual(to other: CGPoint) -> Bool {
    x.isApproximatelyEqual(to: other.x) && y.isApproximatelyEqual(to: other.y)
  }
}

extension CGRect {
  public func isApproximatelyEqual(to other: CGRect) -> Bool {
    origin.isApproximatelyEqual(to: other.origin) && size.isApproximatelyEqual(to: other.size)
  }
}

extension CGSize {
  public func isApproximatelyEqual(to other: CGSize) -> Bool {
    width.isApproximatelyEqual(to: other.width) && height.isApproximatelyEqual(to: other.height)
  }
}
