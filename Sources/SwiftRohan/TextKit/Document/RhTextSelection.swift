// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/// Text selection.
/// - Note: "Rh" for "Rohan" to avoid name conflict with ``TextSelection``.
public struct RhTextSelection: CustomStringConvertible {
  let anchor: TextLocation
  let focus: TextLocation

  /// Whether the selection is reversed, i.e., anchor is after focus.
  let isReversed: Bool

  /// Values that describe the visual location of the text cursor, or the
  /// direction of the **non-anchored** edge of the selection.
  let affinity: SelectionAffinity

  /// The effective text range of the selection, which may be wider than the
  /// extent of the anchor and focus.
  let textRange: RhTextRange

  init(_ location: TextLocation, affinity: SelectionAffinity) {
    anchor = location
    focus = location
    isReversed = false
    textRange = RhTextRange(location)
    self.affinity = affinity
  }

  init(_ location: AffineLocation) {
    anchor = location.value
    focus = location.value
    isReversed = false
    textRange = RhTextRange(location.value)
    affinity = location.affinity
  }

  init(_ textRange: RhTextRange, affinity: SelectionAffinity) {
    anchor = textRange.location
    focus = textRange.endLocation
    isReversed = false
    self.textRange = textRange
    self.affinity = affinity
  }

  init?(
    _ anchor: TextLocation, _ focus: TextLocation, _ textRange: RhTextRange,
    affinity: SelectionAffinity
  ) {
    self.anchor = anchor
    self.focus = focus
    self.textRange = textRange
    guard let compareResult = anchor.compare(focus) else { return nil }
    self.isReversed = compareResult == .orderedDescending
    self.affinity = affinity
  }

  public var description: String { debugDescription }
}

extension RhTextSelection: CustomDebugStringConvertible {
  public var debugDescription: String {
    if anchor == focus {
      return "(\(focus), \(affinity))"
    }
    else if !isReversed {
      return "(anchor: \(anchor); focus: \(focus), \(affinity); range: \(textRange))"
    }
    else {
      return
        "(focus: \(focus), \(affinity); anchor: \(anchor); range: \(textRange))"
    }
  }
}

extension SelectionAffinity: @retroactive CustomStringConvertible {
  public var description: String {
    switch self {
    case .downstream:
      return "downstream"
    case .upstream:
      return "upstream"
    @unknown default:
      assertionFailure("unknown affinity")
      return "unknown"
    }
  }
}
