// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentManager {
  /// Returns insertion indicator frame for the specified text range.
  func insertionIndicatorFrame(
    in textRange: RhTextRange, type: SegmentType,
    options: SegmentOptions = []
  ) -> CGRect? {
    var result: CGRect? = nil
    enumerateTextSegments(in: textRange, type: type, options: options) {
      _, segmentFrame, _ in
      result = segmentFrame
      return false  // discontinue
    }
    return result
  }
}
