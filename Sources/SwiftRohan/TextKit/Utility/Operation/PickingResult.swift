// Copyright 2024-2025 Lie Yan

import Foundation

/// Result for mouse picking.
struct PickingResult {
  /// Range of layout offsets
  let layoutRange: Range<Int>
  /// The fraction of distance from the upstream edge
  let fraction: Double
  /// Affinity of the selection
  let affinity: RhTextSelection.Affinity

  init(
    _ layoutRange: Range<Int>, _ fraction: Double, _ affinity: RhTextSelection.Affinity
  ) {
    self.layoutRange = layoutRange
    self.fraction = fraction
    self.affinity = affinity
  }

  func with(layoutRange: Range<Int>) -> PickingResult {
    PickingResult(layoutRange, fraction, affinity)
  }
}
