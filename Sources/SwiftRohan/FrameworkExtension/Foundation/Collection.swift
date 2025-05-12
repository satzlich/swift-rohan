// Copyright 2024-2025 Lie Yan

import Foundation

extension Collection {
  /// Returns the only element in the collection if there is exactly one
  /// element, otherwise nil.
  @inlinable
  public func getOnlyElement() -> Element? {
    self.count == 1 ? self.first! : nil
  }
}

extension Collection where Element: Equatable {
  /// Returns true if self is a subsequence of other.
  func isSubsequence(of other: Self) -> Bool {
    guard !isEmpty else { return true }
    guard count <= other.count else { return false }

    var i = startIndex
    let end1 = endIndex
    var j = other.startIndex
    let end2 = other.endIndex

    // Invariant: i ← max:k: self[0,k) is subsequence of other[0,j)
    while i < end1 && j < end2 {
      if self[i] == other[j] {
        i = index(after: i)
      }
      j = other.index(after: j)
    }

    return i == end1
  }
}
