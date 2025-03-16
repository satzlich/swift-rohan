// Copyright 2024-2025 Lie Yan

import Foundation

/**
 Return value of insert operations on document, representing the new insertion point.
 */
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
}
