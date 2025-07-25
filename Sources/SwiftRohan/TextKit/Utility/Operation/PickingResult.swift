import Foundation

/// Result for mouse picking.
struct PickingResult {
  /// Range of layout offsets
  let layoutRange: Range<Int>
  /// The fraction of distance from the upstream edge
  let fraction: Double
  /// Affinity of the selection
  let affinity: SelectionAffinity

  init(
    _ layoutRange: Range<Int>, _ fraction: Double, _ affinity: SelectionAffinity
  ) {
    self.layoutRange = layoutRange
    self.fraction = fraction
    self.affinity = affinity
  }

  func with(layoutRange: Range<Int>) -> PickingResult {
    PickingResult(layoutRange, fraction, affinity)
  }

  func with(affinity: SelectionAffinity) -> PickingResult {
    PickingResult(layoutRange, fraction, affinity)
  }
}
