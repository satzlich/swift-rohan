// Copyright 2024-2025 Lie Yan

import Foundation

extension Range<Int> {
  /// Shift the range by a given value.
  @inlinable @inline(__always)
  func subtracting(_ units: Int) -> Range<Bound> {
    let lowerBound = self.lowerBound - units
    let upperBound = self.upperBound - units
    return lowerBound..<upperBound
  }
}
