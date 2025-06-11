// Copyright 2024-2025 Lie Yan

import Foundation

struct SegmentFrame {
  /// frame of the segment
  var frame: CGRect
  /// baseline position measured from the top of the frame
  var baselinePosition: CGFloat

  init(_ frame: CGRect, _ baselinePosition: CGFloat) {
    self.frame = frame
    self.baselinePosition = baselinePosition
  }
}

extension SegmentFrame {
  static func recompose(
    _ segmentFrame: SegmentFrame, ascent: CGFloat, descent: CGFloat
  ) -> SegmentFrame {
    let y = segmentFrame.frame.origin.y + segmentFrame.baselinePosition - ascent

    var segmentFrame = segmentFrame
    segmentFrame.frame.origin.y = y
    segmentFrame.frame.size.height = ascent + descent
    segmentFrame.baselinePosition = ascent

    return segmentFrame
  }
}
