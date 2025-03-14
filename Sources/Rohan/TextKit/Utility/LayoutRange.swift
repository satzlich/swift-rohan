// Copyright 2024-2025 Lie Yan

import Foundation

struct LayoutRange {
  /** layout range with respect to current node */
  let localRange: Range<Int>
  /** layout range with respect to current layout context */
  let contextRange: Range<Int>
  /** fraction of distance from the upstream edge of the segment */
  let fraction: Double

  /** layout length in the range */
  var count: Int { localRange.count }
  /** whether the layout range is empty */
  var isEmpty: Bool { localRange.isEmpty }

  init(_ localRange: Range<Int>, _ contextRange: Range<Int>, _ fraction: Double) {
    precondition(localRange.count == contextRange.count)
    self.localRange = localRange
    self.contextRange = contextRange
    self.fraction = fraction
  }

  func with(localRange: Range<Int>) -> LayoutRange {
    LayoutRange(localRange, contextRange, fraction)
  }
}
