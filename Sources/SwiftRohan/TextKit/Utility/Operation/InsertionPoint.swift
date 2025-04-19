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
}
