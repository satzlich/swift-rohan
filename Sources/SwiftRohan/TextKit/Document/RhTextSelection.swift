// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

/// Text selection.
/// - Note: "Rh" for "Rohan" to avoid name conflict with ``TextSelection``.
public struct RhTextSelection: CustomStringConvertible {
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

  init(_ textRange: RhTextRange, affinity: Affinity = .downstream) {
    anchor = textRange.location
    focus = textRange.endLocation
    isReversed = false
    self.textRange = textRange
    self.affinity = affinity
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
    self.affinity = affinity
  }

  public var description: String {
    if anchor == focus {
      return "(location: \(anchor), affinity: \(affinity))"
    }
    else {
      return
        """
        (anchor: \(anchor), focus: \(focus), reversed: \(isReversed), affinity: \(affinity))
        """
    }
  }
}

extension TextAffinity: @retroactive CustomStringConvertible {
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
