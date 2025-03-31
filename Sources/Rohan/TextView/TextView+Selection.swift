// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  /// Reconcile the highlight regions and insertion indicators with the current
  /// text selection
  func reconcileSelection(withAutoScroll isAutoScrollEnabled: Bool) {
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

      // reconcile insertion indicator and scroll to the indicator
      let indicatorFrame = reconcileInsertionIndicator(for: location)
      if isAutoScrollEnabled, let indicatorFrame { scrollToVisible(indicatorFrame) }
      // add highlight for delimiter
      if let delimiterRange = documentManager.visualDelimiterRange(for: location) {
        addHighlightFrames(for: delimiterRange, type: .delimiter)
      }
    }
    else {
      // reconcile highlight
      selectionView.clearHighlightFrames()
      addHighlightFrames(for: textRange, type: .selection)
      // reconcile insertion indicator and scroll to the indicator
      let indicatorFrame = reconcileInsertionIndicator(for: currentSelection.focus)
      if isAutoScrollEnabled, let indicatorFrame { scrollToVisible(indicatorFrame) }
    }
  }

  /// Reconcile the primary and secondary insertion indicators with the given location
  /// - Parameter location: the location of the insertion indicator
  /// - Returns: the frame of the primary insertion indicator
  private func reconcileInsertionIndicator(for location: TextLocation) -> CGRect? {
    let textRange = RhTextRange(location)
    // clear secondary indicators
    insertionIndicatorView.clearSecondaryIndicators()
    // add primary and secondary indicators
    var count = 0
    var primaryIndicatorFrame: CGRect?
    documentManager.enumerateTextSegments(in: textRange, type: .selection) {
      (_, textSegmentFrame, _) in
      if count == 0 {
        insertionIndicatorView.showPrimaryIndicator(textSegmentFrame)
        primaryIndicatorFrame = textSegmentFrame
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
    return primaryIndicatorFrame
  }

  /// Add highlight frames for the given text range
  private func addHighlightFrames(for textRange: RhTextRange, type: HighlightType) {
    documentManager.enumerateTextSegments(in: textRange, type: .selection) {
      (_, textSegmentFrame, _) in
      selectionView.addHighlightFrame(textSegmentFrame, type: type)
      return true  // continue enumeration
    }
  }
}
