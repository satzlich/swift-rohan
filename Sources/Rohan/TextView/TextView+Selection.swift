// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  /// Request redisplay of selection and update of scroll position.
  @MainActor
  func setNeedsUpdate(selection: Bool = false, scroll: Bool = false) {
    precondition(selection || scroll, "At least one of selection or scroll must be true.")

    if selection { _pendingSelectionUpdate = true }
    if scroll { _pendingScrollUpdate = true }

    guard !_isUpdateEnqueued else { return }
    _isUpdateEnqueued = true

    DispatchQueue.main.async {
      self.performPendingUpdates()
    }
  }

  @MainActor
  private func performPendingUpdates() {
    let shouldUpdateSelection = _pendingSelectionUpdate
    let shouldUpdateScroll = _pendingScrollUpdate
    _pendingSelectionUpdate = false
    _pendingScrollUpdate = false
    _isUpdateEnqueued = false

    switch (shouldUpdateSelection, shouldUpdateScroll) {
    case (false, false):
      // do nothing
      break

    case (true, false):
      _ = reconcileSelection(for: documentManager.textSelection)

    case (false, true):
      documentManager.textSelection
        .flatMap(self.insertionIndicatorFrames(for:))
        .and_then { self.scrollToVisible($0.primary) }

    case (true, true):
      reconcileSelection(for: documentManager.textSelection)
        .and_then { self.scrollToVisible($0.primary) }
    }
  }

  /// Reconcile selection highlight and insertion indicators.
  /// - Returns: The frames of insertion indicators.
  private func reconcileSelection(
    for selection: RhTextSelection?
  ) -> (primary: CGRect, secondary: [CGRect])? {
    guard let selection else {
      // clear all
      selectionView.clearHighlightFrames()
      insertionIndicatorView.hidePrimaryIndicator()
      insertionIndicatorView.clearSecondaryIndicators()
      return nil
    }

    let textRange = selection.effectiveRange

    // reconcile highlight frames
    selectionView.clearHighlightFrames()
    if textRange.isEmpty {
      // add visual delimiter
      if let delimiterRange = documentManager.visualDelimiterRange(for: selection.focus) {
        addHighlightFrames(for: delimiterRange, type: .delimiter)
      }
    }
    else {
      // add selection highlight
      addHighlightFrames(for: textRange, type: .selection)
    }

    // set insertion indicators
    let indicatorFrames = insertionIndicatorFrames(for: selection)
    assert(indicatorFrames != nil)
    setInserionIndicators(indicatorFrames)

    return indicatorFrames
  }

  /// Get the insertion indicator frames for the given location
  /// - Returns: The primary and secondary indicator frames.
  private func insertionIndicatorFrames(
    for selection: RhTextSelection
  ) -> (primary: CGRect, secondary: [CGRect])? {
    let textRange = RhTextRange(selection.focus)
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
