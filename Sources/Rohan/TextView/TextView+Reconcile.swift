// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  /// Reconcile the selection highlight and insertion indicators with the current
  /// text selection
  func reconcileSelection() {
    guard let currentSelection = documentManager.textSelection else {
      selectionView.clearHighlightFrames()
      insertionIndicatorView.hidePrimaryIndicator()
      insertionIndicatorView.clearSecondaryIndicators()
      return
    }

    let textRange = currentSelection.effectiveRange
    if textRange.isEmpty {
      // clear
      selectionView.clearHighlightFrames()
      // add
      reconcileInsertionIndicator(for: textRange.location)
    }
    else {
      reconcileHighlight(for: textRange)
      reconcileInsertionIndicator(for: currentSelection.focus)
    }
  }

  /// Reconcile the primary and secondary insertion indicators with the given location
  private func reconcileInsertionIndicator(for location: TextLocation) {
    let textRange = RhTextRange(location)

    insertionIndicatorView.clearSecondaryIndicators()
    // add
    var count = 0
    documentManager.enumerateTextSegments(in: textRange, type: .selection) {
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
    assert(count > 0, "expect at least one text segment")
    // hide primary indicator if there is no text segment
    if count == 0 {
      insertionIndicatorView.hidePrimaryIndicator()
    }
  }

  /// Reconcile the selection highlight with the given text range
  private func reconcileHighlight(for textRange: RhTextRange) {
    // clear
    selectionView.clearHighlightFrames()
    // add
    documentManager.enumerateTextSegments(in: textRange, type: .selection) {
      (_, textSegmentFrame, _) in
      selectionView.addHighlightFrame(textSegmentFrame)
      return true  // continue enumeration
    }
  }
}
