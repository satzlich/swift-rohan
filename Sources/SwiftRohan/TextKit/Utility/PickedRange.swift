// Copyright 2024-2025 Lie Yan

import Foundation

/// The layout range of a segment in the layout context, along with a fraction
/// that indicates a cursor position within the segment.
///
/// The raison d'être of `PickedRange` is to accommodate the use of `ApplyNode`
/// within `ElementNode`.
struct PickedRange {
  /// layout range of the segment with respect to **current node**.
  private let layoutRange: Range<Int>
  /// fraction of distance from the upstream edge of the segment, which denotes
  /// a cursor point within the segment.
  let fraction: Double

  var count: Int { layoutRange.count }
  var isEmpty: Bool { layoutRange.isEmpty }
  var lowerBound: Int { layoutRange.lowerBound }
  var upperBound: Int { layoutRange.upperBound }

  internal init(_ layoutRange: Range<Int>, _ fraction: Double) {
    self.layoutRange = layoutRange
    self.fraction = fraction
  }

  /// Subtract consumed units from the range.
  internal func smartSubtracting(_ consumed: Int) -> PickedRange {
    precondition(consumed <= layoutRange.lowerBound)
    let range = layoutRange.shiftedBy(delta: -consumed)
    return PickedRange(range, fraction)
  }
}
