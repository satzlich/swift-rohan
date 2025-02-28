// Copyright 2024-2025 Lie Yan

import Foundation

struct DeletionRange {
  let textRange: RhTextRange
  /**
   True if the range should be deleted immediately; otherwise, deletion can
   be delayed. In the latter case, the caller can choose to highlight the
   range to be deleted as a signal to the user.
   */
  let immediate: Bool

  init(_ textRange: RhTextRange, _ immediate: Bool) {
    self.textRange = textRange
    self.immediate = immediate
  }
}
