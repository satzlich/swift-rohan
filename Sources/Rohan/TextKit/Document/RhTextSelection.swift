// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/**
 Text selection.

 - Note: "Rh" for "Rohan" to avoid name conflict with ``TextSelection``.
 */
public struct RhTextSelection {  // text selection is an insertion point
  public var textRanges: [RhTextRange] = []
}
