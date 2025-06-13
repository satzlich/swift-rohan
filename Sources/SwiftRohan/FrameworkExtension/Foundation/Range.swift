// Copyright 2024-2025 Lie Yan

import Foundation

extension Range<Int> {
  /// Shift the range by a given value.
  @inlinable @inline(__always)
  func shiftedBy(delta: Int) -> Range<Bound> {
    let lowerBound = self.lowerBound + delta
    let upperBound = self.upperBound + delta
    return lowerBound..<upperBound
  }
}
