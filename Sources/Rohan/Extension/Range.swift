// Copyright 2024-2025 Lie Yan

import Foundation

extension Range where Bound == Int {
  /// Subtracts a value from the lower and upper bound of the range.
  func subtracting(_ value: Int) -> Range<Bound> {
    let lowerBound = self.lowerBound - value
    let upperBound = self.upperBound - value
    return lowerBound..<upperBound
  }
}
