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
      // clear highlight
      selectionView.clearHighlightFrames()

      let location = textRange.location
      // reconcile insertion indicator
      reconcileInsertionIndicator(for: location)

      // add highlight for delimiter
      if let delimiterRange = documentManager.visualDelimiterRange(from: location) {
        addHighlight(for: delimiterRange, type: .highlight)
      }
    }
    else {
      // reconcile highlight
      selectionView.clearHighlightFrames()
      addHighlight(for: textRange)
      // reconcile insertion indicator
      reconcileInsertionIndicator(for: currentSelection.focus)
    }
  }

  /// Reconcile the primary and secondary insertion indicators with the given location
  private func reconcileInsertionIndicator(for location: TextLocation) {
    let textRange = RhTextRange(location)
    // clear secondary indicators
    insertionIndicatorView.clearSecondaryIndicators()
    // add primary and secondary indicators
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

  /// Add highlight frames for the given text range
  private func addHighlight(for textRange: RhTextRange, type: HighlightType = .selection)
  {
    documentManager.enumerateTextSegments(in: textRange, type: .selection) {
      (_, textSegmentFrame, _) in
      selectionView.addHighlightFrame(textSegmentFrame, type: type)
      return true  // continue enumeration
    }
  }
}
