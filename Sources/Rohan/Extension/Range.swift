// Copyright 2024-2025 Lie Yan

import Foundation

extension Range where Bound == Int {
  /**
   Returns a new range with the same length, but with the lower bound relative
   to a new reference lower bound.
   */
  func relative(to refLowerBound: Int) -> Range<Bound> {
    let lowerBound = self.lowerBound - refLowerBound
    let upperBound = self.upperBound - refLowerBound
    return lowerBound..<upperBound
  }
}
