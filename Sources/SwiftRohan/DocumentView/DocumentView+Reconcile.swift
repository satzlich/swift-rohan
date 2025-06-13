// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  // MARK: - Change

  internal func beginEditing() {
    precondition(_isEditing == false)
    _isEditing = true
  }

  /// - Parameter notifyChange: If true, post `documentDidChange` notification.
  internal func endEditing(notifyChange: Bool = true) {
    precondition(_isEditing == true)
    _isEditing = false
    documentContentDidChange(notifyChange: notifyChange)
  }

  /// - Parameter notifyChange: If true, post `documentDidChange` notification.
  internal func documentContentDidChange(
    layoutScope: DocumentManager.LayoutScope = .viewport,
    notifyChange: Bool = true
  ) {
    // NOTE: It's important to reconcile content storage otherwise non-TextKit
    //  layout may be delayed until next layout cycle, which may lead to unexpected
    //  behavior, eg., `firstRect(...)` may return wrong rect
    documentManager.reconcileLayout(scope: layoutScope)
    // request updates
    needsLayout = true
    setNeedsUpdate(selection: true, scroll: true)

    // post notification
    if notifyChange {
      self.delegate?.documentDidChange(self)
    }
  }

  internal func documentStyleDidChange() {
    documentManager.reconcileLayout(scope: .document)

    needsLayout = true
    setNeedsUpdate(selection: true, scroll: true)
  }

  internal func documentSelectionDidChange(scroll: Bool = false) {
    setNeedsUpdate(selection: true, scroll: scroll)
  }

  // MARK: - Selection + Scroll

  /// Request redisplay of selection and update of scroll position.
  @MainActor
  func setNeedsUpdate(selection: Bool = false, scroll: Bool = false) {
    precondition(selection || scroll)

    if selection { _pendingSelectionUpdate = true }
    if scroll { _pendingScrollUpdate = true }

    guard !_isUpdateEnqueued else { return }
    _isUpdateEnqueued = true

    DispatchQueue.main.async {
      self.performPendingUpdates()
    }
  }

  /// Force redisplay of selection and update of scroll position.
  func forceUpdate(selection: Bool = false, scroll: Bool = false) {
    precondition(selection || scroll)

    if selection { _pendingSelectionUpdate = true }
    if scroll { _pendingScrollUpdate = true }

    performPendingUpdates()
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
      _ = _reconcileSelection(for: documentManager.textSelection)

    case (false, true):
      documentManager.textSelection
        .flatMap(self._insertionIndicatorFrames(for:))
        .and_then { primary, _ in
          self.scrollToVisible(convertToViewRect(primary))
        }

    case (true, true):
      _reconcileSelection(for: documentManager.textSelection)
        .and_then { primary, _ in
          self.scrollToVisible(convertToViewRect(primary))
        }
    }

    func convertToViewRect(_ rect: CGRect) -> CGRect {
      contentView.convert(rect, to: self)
        .insetBy(dx: -10, dy: -10)  // add padding
    }
  }

  /// Reconcile selection highlight and insertion indicators.
  /// - Returns: The frames of insertion indicators.
  private func _reconcileSelection(
    for selection: RhTextSelection?
  ) -> (primary: CGRect, secondary: [CGRect])? {
    guard let selection else {
      // clear all
      selectionView.clearHighlightFrames()
      insertionIndicatorView.hidePrimaryIndicator()
      insertionIndicatorView.clearSecondaryIndicators()
      return nil
    }

    let textRange = selection.textRange

    // reconcile highlight frames
    selectionView.clearHighlightFrames()
    if textRange.isEmpty {
      // add visual delimiter
      if isVisualDelimiterEnabled,
        let (delimiterRange, level) =
          documentManager.visualDelimiterRange(for: selection.focus)
      {
        _addHighlightFrames(for: delimiterRange, type: .delimiter(level: level))
      }
    }
    else {
      // add selection highlight
      _addHighlightFrames(for: textRange, type: .selection)
    }

    // set insertion indicators
    let indicatorFrames = _insertionIndicatorFrames(for: selection)
    assert(indicatorFrames != nil)
    _setInserionIndicators(indicatorFrames)

    return indicatorFrames
  }

  /// Get the insertion indicator frames for the given location
  /// - Returns: The primary and secondary indicator frames.
  private func _insertionIndicatorFrames(
    for selection: RhTextSelection
  ) -> (primary: CGRect, secondary: [CGRect])? {

    let textRange = RhTextRange(selection.focus)
    var primaryIndicatorFrame: CGRect?
    var secondaryIndicatorFrames: [CGRect] = []

    let options: DocumentManager.SegmentOptions =
      (selection.affinity == .upstream) ? .upstreamAffinity : []

    documentManager.enumerateTextSegments(
      in: textRange, type: .selection, options: options
    ) { (_, textSegmentFrame, _) in
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
  private func _setInserionIndicators(_ frames: (primary: CGRect, secondary: [CGRect])?) {
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
  private func _addHighlightFrames(for textRange: RhTextRange, type: HighlightType) {
    documentManager.enumerateTextSegments(in: textRange, type: .selection) {
      (_, textSegmentFrame, _) in
      selectionView.addHighlightFrame(textSegmentFrame, type: type)
      return true  // continue
    }
  }

  public override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    // add observers for focus change
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFocusChange(_:)),
      name: NSWindow.didBecomeKeyNotification,
      object: self.window
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFocusChange(_:)),
      name: NSWindow.didResignKeyNotification,
      object: self.window)
  }

  public override func viewWillMove(toWindow newWindow: NSWindow?) {
    super.viewWillMove(toWindow: newWindow)

    // remove observers
    NotificationCenter.default.removeObserver(
      self, name: NSWindow.didBecomeKeyNotification, object: nil)
    NotificationCenter.default.removeObserver(
      self, name: NSWindow.didResignKeyNotification, object: nil)
  }

  /// Handle focus change notification
  @objc private func handleFocusChange(_ notification: Notification) {
    // Let insertion indicators blink when the text view is focused.
    // And stop blinking when it is blurred.

    if notification.name == NSWindow.didBecomeKeyNotification {
      if self.window?.firstResponder == self {
        insertionIndicatorView.startBlinking()
      }
    }
    else {
      insertionIndicatorView.stopBlinking()
    }
  }
}
