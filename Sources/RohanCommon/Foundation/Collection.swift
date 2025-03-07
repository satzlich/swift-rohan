// Copyright 2024-2025 Lie Yan

import Foundation

extension Collection {
  /** Returns the single element if this collection is a singleton; or nil otherwise */
  @inlinable
  public func getOnlyElement() -> Element? {
    self.count == 1 ? self[startIndex] : nil
  }
}
