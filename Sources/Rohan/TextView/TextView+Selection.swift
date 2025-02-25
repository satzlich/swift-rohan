// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  func reconcileSelection() {
    guard let textRange = documentManager.textSelection?.getOnlyRange() else { return }
    if textRange.isEmpty {
      // clear
      selectionView.clearHighlightFrames()
      insertionIndicatorView.clearSecondaryIndicators()
      // add
      var count = 0
      documentManager.enumerateTextSegments(in: textRange, type: .standard) {
        (_, textSegmentFrame, _) in
        if count == 0 {
          insertionIndicatorView.showPrimaryIndicator(textSegmentFrame)
        }
        else {
          insertionIndicatorView.addSecondaryIndicator(textSegmentFrame)
        }
        count += 1
        return true  // continue enumeration
      }
    }
    else {
      // clear
      selectionView.clearHighlightFrames()
      insertionIndicatorView.hidePrimaryIndicator()
      insertionIndicatorView.clearSecondaryIndicators()
      // add
      documentManager.enumerateTextSegments(in: textRange, type: .standard) {
        (_, textSegmentFrame, _) in
        selectionView.addHighlightFrame(textSegmentFrame)
        return true  // continue enumeration
      }
    }
  }
}
