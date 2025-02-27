// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/**
 Text selection.
 - Note: "Rh" for "Rohan" to avoid name conflict with ``TextSelection``.
 */
public struct RhTextSelection: CustomDebugStringConvertible {
  private let textRange: RhTextRange

  /** Initialize a text selection with a single insertion point. */
  init(_ location: TextLocation) {
    self.textRange = RhTextRange(location)
  }

  /** Initialize a text selection with a range */
  init(_ textRange: RhTextRange) {
    self.textRange = textRange
  }

  /** Returns the text range if there is a single one; nil, otherwise */
  func getTextRange() -> RhTextRange? {
    textRange
  }

  public var debugDescription: String {
    textRange.debugDescription
  }
}
