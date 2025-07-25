import Foundation
import Numerics

extension BinaryFloatingPoint {
  @inlinable @inline(__always)
  func isNearlyEqual(to other: Self) -> Bool {
    isApproximatelyEqual(to: other)
  }

  @inlinable @inline(__always)
  func isNearlyEqual(to other: Self, absoluteTolerance: Self) -> Bool {
    isApproximatelyEqual(to: other, absoluteTolerance: absoluteTolerance)
  }
}
