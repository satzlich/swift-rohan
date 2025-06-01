// Copyright 2024-2025 Lie Yan

import Foundation

extension CGFloat {
  /// Clamps the value between `min+inset` and `max-inset` if possible;
  /// otherwise, clamps it between `min` and `max`.
  internal func clamped(_ min: CGFloat, _ max: CGFloat, inset: CGFloat) -> CGFloat {
    precondition(min <= max)
    precondition(inset >= 0)

    if min + inset > max - inset {
      return self.clamped(min, max)
    }
    else {
      return self.clamped(min + inset, max - inset)
    }
  }
}
