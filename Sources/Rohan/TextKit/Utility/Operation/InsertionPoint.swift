// Copyright 2024-2025 Lie Yan

import Foundation

/// Insertion point resulted from insert operation.
public struct InsertionPoint {
  /// The location of the insertion point.
  let location: TextLocation
  /// True if the insertion point is guaranteed to be the same as the original;
  /// false if the insertion point is potentially different from the original
  let isSame: Bool

  init(_ location: TextLocation, isSame: Bool) {
    self.location = location
    self.isSame = isSame
  }

  /**
   Combine two successive insertion points into one.

   - Invariant: Denote ``combined(with:)`` by ⊕. Given a sequence of insertion
      points `p_1, p_2, ..., p_n`, then `p_1 ⊕ p_2 ⊕ ... ⊕ p_n` satisfies the
      following:
        a) property `location` equals `p_n.location`;
        b) property `isSame` equals `p_1.isSame ∧ p_2.isSame ∧ ... ∧ p_n.isSame`.
   */
  func combined(with next: InsertionPoint) -> InsertionPoint {
    if next.isSame {
      assert(location == next.location)
      return self
    }
    return next
  }
}
