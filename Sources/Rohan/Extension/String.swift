// Copyright 2024-2025 Lie Yan

import Foundation

extension String {
  @inline(__always) var length: Int { utf16.count }
}

extension String {
  /// Returns true if self is a subsequence of other.
  func isSubsequence(of other: String) -> Bool {
    guard !self.isEmpty else { return true }
    guard self.count <= other.count else { return false }

    var index = self.startIndex

    for char in other {
      if char == self[index] {
        index = self.index(after: index)
        if index == self.endIndex { return true }
      }
    }
    return false
  }
}
