// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  func reconcileSelection() {
    insertionIndicatorView.clearInsertionIndicators()
    selectionView.clearHighlightRegions()

    guard let textRange = documentManager.textSelection?.textRanges.first else { return }
    if textRange.isEmpty {
      documentManager.enumerateTextSegments(in: textRange, type: .standard) {
        (_, textSegmentFrame, baselinePosition) in
        insertionIndicatorView.addInsertionIndicator(textSegmentFrame)
        return false  // stop enumeration
      }
    }
    else {
      documentManager.enumerateTextSegments(in: textRange, type: .standard) {
        (_, textSegmentFrame, _) in
        selectionView.addHighlightRegion(textSegmentFrame)
        return true  // continue enumeration
      }
    }
  }
}
