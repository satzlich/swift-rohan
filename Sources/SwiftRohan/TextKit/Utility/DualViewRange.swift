// Copyright 2024-2025 Lie Yan

import Foundation

/// The layout range of a sement in the layout context, maintained in
/// two different views.
///
/// The raison d'être of `DualViewRange` is to accommodate the use of `ApplyNode`.
/// The invariant maintained by `DualViewRange` is involved. Use and modify this
/// struct with care.
///
/// - Invariant: The local range and the context range correspond to the
///     same segment in the layout context.
struct DualViewRange {
  /// layout range with respect to current node
  let localRange: Range<Int>
  /// layout range with respect to current layout context
  let contextRange: Range<Int>
  /// fraction of distance from the upstream edge of the segment, which denotes
  /// a cursor point within the segment.
  let fraction: Double

  /// layout length in the range
  var count: Int { localRange.count }
  /// Returns true if the range is empty
  var isEmpty: Bool { localRange.isEmpty }

  internal init(_ contextRange: Range<Int>, _ fraction: Double) {
    self.localRange = contextRange
    self.contextRange = contextRange
    self.fraction = fraction
  }

  private init(_ localRange: Range<Int>, _ contextRange: Range<Int>, _ fraction: Double) {
    precondition(localRange.count == contextRange.count)
    self.localRange = localRange
    self.contextRange = contextRange
    self.fraction = fraction
  }

  /// Subtract consumed units from the range.
  internal func smartSubtracting(_ consumed: Int) -> DualViewRange {
    if consumed <= localRange.lowerBound {
      let range = localRange.shiftedBy(delta: -consumed)
      return DualViewRange(range, contextRange, fraction)
    }
    else if consumed <= localRange.upperBound {
      let delta = consumed - localRange.lowerBound
      let localLower = consumed
      let contextLower = contextRange.lowerBound + delta
      let frac = Self.fractionValue(of: fraction, localRange, localLower)
      return DualViewRange(
        localLower..<localRange.upperBound,
        contextLower..<contextRange.upperBound,
        frac.clamped(0, 1))
    }
    else {
      let delta = consumed - localRange.lowerBound
      let localLower = consumed
      let contextLower = contextRange.lowerBound + delta
      let frac = 0.0
      return DualViewRange(localLower..<localLower, contextLower..<contextLower, frac)
    }
  }

  /// Given a fraction for a location in range, return the new fraction for the
  /// location when lower bound of range moves to x.
  /// - Parameters:
  ///   - fraction: The fraction value of the location in the range.
  ///   - range: The range in which the location resides.
  ///   - target: The new lower bound of the range.
  private static func fractionValue(
    of fraction: Double, _ range: Range<Int>, _ target: Int
  ) -> Double {
    precondition(0 <= fraction && fraction <= 1)
    let location = Double(range.count) * fraction + Double(range.lowerBound)
    let target = Double(target)
    let newLength = Double(range.upperBound) - target
    return (location - target) / newLength
  }
}
