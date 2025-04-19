// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/// Text selection.
/// - Note: "Rh" for "Rohan" to avoid name conflict with ``TextSelection``.
public struct RhTextSelection: CustomDebugStringConvertible {
  let anchor: TextLocation
  let focus: TextLocation
  let isReversed: Bool
  /// textRange may not equal to `[anchor, focus)` or `[focus, anchor)`
  let textRange: RhTextRange

  init(_ location: TextLocation) {
    anchor = location
    focus = location
    isReversed = false
    textRange = RhTextRange(location)
  }

  init(_ textRange: RhTextRange) {
    anchor = textRange.location
    focus = textRange.endLocation
    isReversed = false
    self.textRange = textRange
  }

  init?(_ anchor: TextLocation, _ focus: TextLocation, _ textRange: RhTextRange) {
    self.anchor = anchor
    self.focus = focus
    self.textRange = textRange
    guard let compareResult = anchor.compare(focus) else { return nil }
    self.isReversed = compareResult == .orderedDescending
  }

  /// Returns the smaller one of anchor and focus.
  func getLocation() -> TextLocation {
    !isReversed ? anchor : focus
  }

  /// Returns the greater one of anchor and focus.
  func getEndLocation() -> TextLocation {
    !isReversed ? focus : anchor
  }

  public var debugDescription: String {
    if anchor == focus {
      return "location: \(anchor)"
    }
    else {
      return "anchor: \(anchor), focus: \(focus), reversed: \(isReversed)"
    }
  }
}
