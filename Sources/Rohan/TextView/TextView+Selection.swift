// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  /// Request redisplay of selection and update of scroll position.
  func setNeedsUpdate(selection: Bool = false, scroll: Bool = false) {
    if selection { _needsSelectionUpdate = true }
    if scroll { _needsScrollUpdate = true }
    if _needsSelectionUpdate || _needsScrollUpdate {
      DispatchQueue.main.async {
        self.performPendingUpdates()
      }
    }
  }

  private func performPendingUpdates() {
    var scrollTarget: CGRect? = nil

    if _needsSelectionUpdate {
      scrollTarget = reconcileSelection(for: documentManager.textSelection)
      _needsSelectionUpdate = false
    }

    if _needsScrollUpdate {
      if let target = scrollTarget {
        scrollToVisible(target)
      }
      _needsScrollUpdate = false
    }
  }

  /// Reconcile selection highlight and insertion indicators.
  /// - Returns: The frame of the primary insertion indicator.
  private func reconcileSelection(for selection: RhTextSelection?) -> CGRect? {
    guard let selection else {
      // clear all
      selectionView.clearHighlightFrames()
      insertionIndicatorView.hidePrimaryIndicator()
      insertionIndicatorView.clearSecondaryIndicators()
      return nil
    }

    let textRange = selection.effectiveRange
    let rangeIsEmpty = textRange.isEmpty
    let indicatorLocation = rangeIsEmpty ? textRange.location : selection.focus

    // reconcile highlight frames
    if rangeIsEmpty {
      // clear selection
      selectionView.clearHighlightFrames()
      // add visual delimiter
      if let delimiterRange = documentManager.visualDelimiterRange(for: indicatorLocation)
      {
        addHighlightFrames(for: delimiterRange, type: .delimiter)
      }
    }
    else {
      // add selection highlight
      selectionView.clearHighlightFrames()
      addHighlightFrames(for: textRange, type: .selection)
    }

    // set insertion indicators
    let indicatorFrames = insertionIndicatorFrames(for: indicatorLocation)
    setInserionIndicators(indicatorFrames)

    return indicatorFrames.map { $0.primary }
  }

  /// Get the insertion indicator frames for the given location
  /// - Returns: The primary and secondary indicator frames.
  private func insertionIndicatorFrames(
    for location: TextLocation
  ) -> (primary: CGRect, secondary: [CGRect])? {
    let textRange = RhTextRange(location)
    var primaryIndicatorFrame: CGRect?
    var secondaryIndicatorFrames: [CGRect] = []
    documentManager.enumerateTextSegments(in: textRange, type: .selection) {
      (_, textSegmentFrame, _) in
      if primaryIndicatorFrame == nil {
        primaryIndicatorFrame = textSegmentFrame
      }
      else {
        secondaryIndicatorFrames.append(textSegmentFrame)
      }
      return true  // continue
    }
    return primaryIndicatorFrame.map { ($0, secondaryIndicatorFrames) }
  }

  /// Set insertion indicators for the given frames.
  private func setInserionIndicators(_ frames: (primary: CGRect, secondary: [CGRect])?) {
    guard let (primary, secondaries) = frames else {
      insertionIndicatorView.hidePrimaryIndicator()
      insertionIndicatorView.clearSecondaryIndicators()
      return
    }
    insertionIndicatorView.showPrimaryIndicator(primary)
    insertionIndicatorView.clearSecondaryIndicators()
    for secondary in secondaries {
      insertionIndicatorView.addSecondaryIndicator(secondary)
    }
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
