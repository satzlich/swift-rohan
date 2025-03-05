// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/**
 Text selection.
 - Note: "Rh" for "Rohan" to avoid name conflict with ``TextSelection``.
 */
public struct RhTextSelection: CustomDebugStringConvertible {
  let anchor: TextLocation
  let focus: TextLocation
  let reversed: Bool
  /**
   effective range if it is not equal to `[anchor, focus)` or `[focus, anchor)`
   */
  let effectiveRange: RhTextRange?

  init(_ location: TextLocation) {
    anchor = location
    focus = location
    reversed = false
    effectiveRange = nil
  }

  init(_ textRange: RhTextRange) {
    anchor = textRange.location
    focus = textRange.endLocation
    reversed = false
    effectiveRange = nil
  }

  init?(
    _ anchor: TextLocation, _ focus: TextLocation,
    _ effectiveRange: RhTextRange
  ) {
    self.anchor = anchor
    self.focus = focus
    self.effectiveRange = effectiveRange
    guard let compareResult = anchor.compare(focus) else { return nil }
    self.reversed = compareResult == .orderedDescending
  }

  func getLocation() -> TextLocation {
    reversed ? focus : anchor
  }

  func getEndLocation() -> TextLocation {
    reversed ? anchor : focus
  }

  /** Returns the text range if there is a single one; nil, otherwise */
  func getEffectiveRange() -> RhTextRange? {
    if effectiveRange != nil {
      return effectiveRange
    }
    else if !reversed {
      return RhTextRange(anchor, focus)
    }
    else {
      return RhTextRange(focus, anchor)
    }
  }

  public var debugDescription: String {
    "anchor: \(anchor), focus: \(focus), reversed: \(reversed)"
  }
}
