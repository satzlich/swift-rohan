// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  func reconcileSelection() {
    guard let textRange = documentManager.textSelection?.getOnlyRange() else { return }
    if textRange.isEmpty {
      // clear
      selectionView.clearHighlightRegions()
      insertionIndicatorView.clearSecondaryIndicators()
      // add
      var primary: Bool = true
      documentManager.enumerateTextSegments(in: textRange, type: .standard) {
        (_, textSegmentFrame, baselinePosition) in
        if primary {
          insertionIndicatorView.showPrimaryIndicator(textSegmentFrame)
          primary = false
        }
        else {
          insertionIndicatorView.addSecondaryIndicator(textSegmentFrame)
        }
        return true  // continue enumeration
      }
    }
    else {
      // clear
      selectionView.clearHighlightRegions()
      insertionIndicatorView.hidePrimaryIndicator()
      insertionIndicatorView.clearSecondaryIndicators()
      // add
      documentManager.enumerateTextSegments(in: textRange, type: .standard) {
        (_, textSegmentFrame, _) in
        selectionView.addHighlightRegion(textSegmentFrame)
        return true  // continue enumeration
      }
    }
  }
}
