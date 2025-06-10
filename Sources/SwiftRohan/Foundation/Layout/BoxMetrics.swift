// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation

struct BoxMetrics: Equatable, Hashable {
  let width: CGFloat
  let ascent: CGFloat
  let descent: CGFloat

  init(width: CGFloat, ascent: CGFloat, descent: CGFloat) {
    self.width = width
    self.ascent = ascent
    self.descent = descent
  }

  func isNearlyEqual(to other: BoxMetrics) -> Bool {
    width.isNearlyEqual(to: other.width)
      && ascent.isNearlyEqual(to: other.ascent)
      && descent.isNearlyEqual(to: other.descent)
  }
}

extension BoxMetrics: CustomStringConvertible {
  var description: String {
    let width = String(format: "%.2f", self.width)
    let ascent = String(format: "%.2f", self.ascent)
    let descent = String(format: "%.2f", self.descent)
    return "\(width)×(\(ascent)+\(descent))"
  }
}
