// Copyright 2024-2025 Lie Yan

import Foundation

extension TextView {
  /// Request redisplay of selection and update of scroll position.
  func setNeedsUpdate(selection: Bool = false, scroll: Bool = false) {
    precondition(selection || scroll, "At least one of selection or scroll must be true.")

    _updateLock.withLock {
      if selection { _pendingSelectionUpdate = true }
      if scroll { _pendingScrollUpdate = true }

      guard !_isUpdateEnqueued else { return }
      _isUpdateEnqueued = true

      DispatchQueue.main.async {
        self.performPendingUpdates()
      }
    }
  }

  private func performPendingUpdates() {
    _updateLock.lock()
    let shouldUpdateSelection = _pendingSelectionUpdate
    let shouldUpdateScroll = _pendingScrollUpdate
    _pendingSelectionUpdate = false
    _pendingScrollUpdate = false
    _isUpdateEnqueued = false
    _updateLock.unlock()

    switch (shouldUpdateSelection, shouldUpdateScroll) {
    case (false, false):
      // do nothing
      break

    case (true, false):
      _ = reconcileSelection(for: documentManager.textSelection)

    case (false, true):
      let target: CGRect? = documentManager.textSelection
        .map(\.focus)
        .flatMap(self.insertionIndicatorFrames(for:))
        .map(\.primary)
      if let target {
        scrollToVisible(target)
      }

    case (true, true):
      let indicatorFrame = reconcileSelection(for: documentManager.textSelection)
      if let target = indicatorFrame {
        scrollToVisible(target)
      }
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
    let location = selection.focus

    // reconcile highlight frames
    if textRange.isEmpty {
      // clear selection
      selectionView.clearHighlightFrames()
      // add visual delimiter
      if let delimiterRange = documentManager.visualDelimiterRange(for: location) {
        addHighlightFrames(for: delimiterRange, type: .delimiter)
      }
    }
    else {
      // add selection highlight
      selectionView.clearHighlightFrames()
      addHighlightFrames(for: textRange, type: .selection)
    }

    // set insertion indicators
    let indicatorFrames = insertionIndicatorFrames(for: location)
    setInserionIndicators(indicatorFrames)

    return indicatorFrames.map(\.primary)
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
