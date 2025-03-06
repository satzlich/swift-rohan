// Copyright 2024-2025 Lie Yan

import Foundation

private let MIN_SELECTION_WIDTH: CGFloat = 5

extension TextView {
  func reconcileSelection() {
    guard let currentSelection = documentManager.textSelection
    else {
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
    assert(count > 0, "at least one text segment")
    // FALLBACK: hide primary indicator if there is no text segment
    if count == 0 {
      insertionIndicatorView.hidePrimaryIndicator()
    }
  }

  private func reconcileHighlight(for textRange: RhTextRange) {
    // clear
    selectionView.clearHighlightFrames()
    // add
    documentManager.enumerateTextSegments(in: textRange, type: .selection) {
      (_, textSegmentFrame, _) in

      var textSegmentFrame = textSegmentFrame
      if textSegmentFrame.width == 0 {
        textSegmentFrame.size.width = MIN_SELECTION_WIDTH
      }
      selectionView.addHighlightFrame(textSegmentFrame)
      return true  // continue enumeration
    }
  }
}
