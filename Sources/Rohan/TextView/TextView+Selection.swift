// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  func reconcileSelection() {
    guard let textRange = documentManager.textSelection?.getOnlyRange() else { return }
    if textRange.isEmpty {
      selectionView.clearHighlightRegions()
      documentManager.enumerateTextSegments(in: textRange, type: .standard) {
        (_, textSegmentFrame, baselinePosition) in
        insertionIndicatorView.showInsertionIndicator(textSegmentFrame)
        return false  // stop enumeration
      }
    }
    else {
      selectionView.clearHighlightRegions()
      insertionIndicatorView.hideInsertionIndicator()

      documentManager.enumerateTextSegments(in: textRange, type: .standard) {
        (_, textSegmentFrame, _) in
        selectionView.addHighlightRegion(textSegmentFrame)
        return true  // continue enumeration
      }
    }
  }
}
