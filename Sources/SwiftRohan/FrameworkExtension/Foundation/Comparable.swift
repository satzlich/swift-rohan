import Foundation

extension Comparable {
  @inlinable @inline(__always)
  func clamped(_ min: Self, _ max: Self) -> Self {
    precondition(min <= max, "min > max, or either was NaN. min = \(min), max = \(max)")

    if self < min {
      return min
    }
    else if self > max {
      return max
    }
    else {
      return self
    }
  }
}
