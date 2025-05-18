// Copyright 2024-2025 Lie Yan

import Foundation

extension String {
  @inline(__always) var length: Int { utf16.count }
}

extension String {
  /// Returns index range for the given range of utf16 code units.
  func indexRange(for range: Range<Int>) -> Range<Index> {
    let start = utf16.index(startIndex, offsetBy: range.lowerBound)
    let end = utf16.index(startIndex, offsetBy: range.upperBound)
    return start..<end
  }
}
