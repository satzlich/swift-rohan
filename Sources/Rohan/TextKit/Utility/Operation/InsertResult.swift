// Copyright 2024-2025 Lie Yan

import Foundation

/**
 Return value of insert operations on document, representing the new insertion point.
 */
struct InsertResult {
  /** the new insertion point */
  let insertionPoint: TextLocation
  /** true if the insertion point is the same as the original */
  let isSame: Bool

  init(_ insertionPoint: TextLocation, isSame: Bool) {
    self.insertionPoint = insertionPoint
    self.isSame = isSame
  }
}
