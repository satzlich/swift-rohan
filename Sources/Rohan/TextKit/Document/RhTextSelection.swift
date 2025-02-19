// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/**
 Text selection.
 - Note: "Rh" for "Rohan" to avoid name conflict with ``TextSelection``.
 */
public struct RhTextSelection: CustomDebugStringConvertible {
  public let textRanges: [RhTextRange]

  /** Initialize a text selection with a single insertion point. */
  init(_ location: TextLocation) {
    self.textRanges = [RhTextRange(location)]
  }

  /** Initialize a text selection with a range */
  init(_ range: RhTextRange) {
    textRanges = [range]
  }

  public var debugDescription: String {
    textRanges.getOnlyElement()?.debugDescription ?? "No selection"
  }
}
