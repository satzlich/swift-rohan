// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/// Text selection.
/// - Note: "Rh" for "Rohan" to avoid name conflict with ``TextSelection``.
public struct RhTextSelection: CustomDebugStringConvertible {
  typealias Affinity = NSTextSelection.Affinity

  let anchor: TextLocation
  let focus: TextLocation
  let isReversed: Bool
  /// textRange may not equal to `[anchor, focus)` or `[focus, anchor)`
  let textRange: RhTextRange
  let affinity: Affinity

  init(_ location: TextLocation) {
    anchor = location
    focus = location
    isReversed = false
    textRange = RhTextRange(location)
    self.affinity = .downstream
  }

  init(_ location: AffineLocation) {
    anchor = location.value
    focus = location.value
    isReversed = false
    textRange = RhTextRange(location.value)
    affinity = location.affinity
  }

  init(_ textRange: RhTextRange) {
    anchor = textRange.location
    focus = textRange.endLocation
    isReversed = false
    self.textRange = textRange
    self.affinity = .downstream
  }

  init?(
    _ anchor: TextLocation, _ focus: TextLocation, _ textRange: RhTextRange,
    affinity: Affinity
  ) {
    self.anchor = anchor
    self.focus = focus
    self.textRange = textRange
    guard let compareResult = anchor.compare(focus) else { return nil }
    self.isReversed = compareResult == .orderedDescending
    self.affinity = .downstream
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
    let affinity = self.affinity == .upstream ? "upstream" : "downstream"
    if anchor == focus {
      return "location: \(anchor), affinity: \(affinity)"
    }
    else {
      return
        """
        anchor: \(anchor), focus: \(focus), reversed: \(isReversed), affinity: \(affinity)
        """
    }
  }
}
