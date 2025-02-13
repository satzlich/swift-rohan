// Copyright 2024-2025 Lie Yan

import Foundation

struct SegmentFrame {
  /** frame of the segment where origin is at the natural origin of the segment */
  var frame: CGRect
  /** Baseline position relative to the top of the frame */
  var baselinePosition: CGFloat

  init(_ frame: CGRect, _ baselinePosition: CGFloat) {
    self.frame = frame
    self.baselinePosition = baselinePosition
  }
}
