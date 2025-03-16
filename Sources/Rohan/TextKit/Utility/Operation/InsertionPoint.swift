// Copyright 2024-2025 Lie Yan

import Foundation

/** Insertion point resulted from insert operation. */
struct InsertionPoint {
  /** the new insertion point */
  let insertionPoint: TextLocation
  /**
   True if the insertion point is guaranteed to be the same as the original;
   false if the insertion point is potentially different from the original.
   */
  let isSame: Bool

  init(_ insertionPoint: TextLocation, isSame: Bool) {
    self.insertionPoint = insertionPoint
    self.isSame = isSame
  }

  /**
   Combine two successive insertion points into one.

   - Invariant: Denote combine by ⊕. Given a sequence of insertion points
      `p_1, p_2, ..., p_n`, then `p_1 ⊕ p_2 ⊕ ... ⊕ p_n` satisfies the following:
      a) property `insertionPoint` equals `p_n.insertionPoint`;
      b) property `isSame` equals `p_1.isSame ∧ p_2.isSame ∧ ... ∧ p_n.isSame`.
   */
  func combine(with next: InsertionPoint) -> InsertionPoint {
    if next.isSame {
      assert(insertionPoint == next.insertionPoint)
      return self
    }
    return next
  }
}
