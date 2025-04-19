// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentManager {
  /// Returns the union of text segment frames for the given range.
  func textSegmentFrame(
    in textRange: RhTextRange, type: SegmentType,
    options: SegmentOptions = [.rangeNotRequired, .upstreamAffinity]
  ) -> CGRect? {
    var result: CGRect? = nil
    enumerateTextSegments(in: textRange, type: type, options: options) {
      _, segmentFrame, _ in
      result = result?.union(segmentFrame) ?? segmentFrame
      return true
    }
    return result
  }
}
