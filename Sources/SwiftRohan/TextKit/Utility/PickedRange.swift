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
  /// - Returns: A new `PickedRange` with the consumed units subtracted, or `nil`
  ///     if the consumed units exceed the range **lower bound**.
  internal func subtracting(_ units: Int) -> PickedRange? {
    guard units <= layoutRange.lowerBound else {
      // If the consumed units exceed the range, return nil.
      return nil
    }
    let range = layoutRange.subtracting(units)
    return PickedRange(range, fraction)
  }
}
