// Copyright 2024-2025 Lie Yan

import Foundation

extension Collection {
  /// Returns the only element in the collection if there is exactly one
  /// element, otherwise nil.
  @inlinable
  public func getOnlyElement() -> Element? {
    self.count == 1 ? self[startIndex] : nil
  }
}
