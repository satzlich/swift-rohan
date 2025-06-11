// Copyright 2024-2025 Lie Yan

import Foundation

struct LayoutRange {
  /// layout range with respect to current node
  let localRange: Range<Int>
  /// layout range with respect to current layout context
  let contextRange: Range<Int>
  /// fraction of distance from the upstream edge of the segment
  let fraction: Double

  /// layout length in the range
  var count: Int { localRange.count }
  /// Returns true if the range is empty
  var isEmpty: Bool { localRange.isEmpty }

  init(_ localRange: Range<Int>, _ contextRange: Range<Int>, _ fraction: Double) {
    precondition(localRange.count == contextRange.count)
    self.localRange = localRange
    self.contextRange = contextRange
    self.fraction = fraction
  }

  /// Subtract consumed units from the range.
  func safeSubtracting(_ consumed: Int) -> LayoutRange {
    if consumed <= localRange.lowerBound {
      let range = localRange.subtracting(consumed)
      return LayoutRange(range, contextRange, fraction)
    }
    else if consumed <= localRange.upperBound {
      let delta = consumed - localRange.lowerBound
      let localLower = consumed
      let contextLower = contextRange.lowerBound + delta
      let frac = Self.fractionValue(of: fraction, localRange, localLower)
      return LayoutRange(
        localLower..<localRange.upperBound,
        contextLower..<contextRange.upperBound,
        frac.clamped(0, 1))
    }
    else {
      let delta = consumed - localRange.lowerBound
      let localLower = consumed
      let contextLower = contextRange.lowerBound + delta
      let frac = 0.0
      return LayoutRange(localLower..<localLower, contextLower..<contextLower, frac)
    }
  }
  /// Given a fraction for a location in range, return the new fraction for the
  /// location when lower bound of range moves to x.
  private static func fractionValue(of f: Double, _ range: Range<Int>, _ x: Int) -> Double
  {
    let location = Double(range.count) * f + Double(range.lowerBound)
    let x = Double(x)
    let newLength = Double(range.upperBound) - x
    return (location - x) / newLength
  }
}
