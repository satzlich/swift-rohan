// Copyright 2024-2025 Lie Yan

import Foundation

extension DocumentManager {
  /// Returns the primary insertion indicator frame for the given text location.
  func primaryInsertionIndicatorFrame(
    at location: TextLocation, _ affinity: SelectionAffinity
  ) -> CGRect? {
    let range = RhTextRange(location)
    let options: DocumentManager.SegmentOptions =
      affinity == .upstream ? .upstreamAffinity : []

    var result: CGRect? = nil
    enumerateTextSegments(in: range, type: .standard, options: options) {
      _, segmentFrame, _ in
      result = segmentFrame
      return false  // discontinue
    }
    return result
  }
}
