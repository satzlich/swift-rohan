// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public override func complete(_ sender: Any?) {
    Rohan.logger.debug("complete")

    guard let range = self.documentManager.textSelection?.effectiveRange,
      range.isEmpty
    else {
      Rohan.logger.debug("complete: location is not empty")
      self.notifyOperationRejected()
      return
    }

    triggerCompletion(query: "h", location: range.location)
  }

  public override func cancelOperation(_ sender: Any?) {
    Rohan.logger.debug("cancelOepration")

    if let _completionWindowController,
      _completionWindowController.isVisible
    {
      _completionWindowController.close()
    }
    else {
      self.complete(sender)
    }
  }

  // MARK: - Private

  /// Trigger completion with the given query.
  private func triggerCompletion(query: String, location: TextLocation) {
    // ensure completion provider is ready
    guard self.completionProvider != nil
    else {
      self.notifyAutoCompleteNotReady()
      return
    }
    // ensure location is valid
    guard let containerCategory = documentManager.containerCategory(for: location)
    else {
      Rohan.logger.debug("triggerCompletion: container category is nil")
      return
    }

    // cancel previous task
    self.cancelCompletion()

    // record query time
    let currentQueryTime = Date()
    _lastCompletionQueryTime = currentQueryTime
    let maxResults = _maxCompletionResults

    // assign new task
    _completionTask = Task { [weak self] in
      guard !Task.isCancelled else { return }

      // debounce typing
      let debounceInterval: TimeInterval = 0.2
      try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1e9))

      guard !Task.isCancelled else { return }

      // validate query freshness
      guard self?._lastCompletionQueryTime == currentQueryTime else { return }

      // get results from provider
      guard let provider = self?.completionProvider else { return }
      let results =
        provider.getCompletions(query, containerCategory, maxResults: maxResults)

      #if DEBUG && SIMULATE_COMPLETION_DELAY
      try? await Task.sleep(nanoseconds: UInt64(0.8e9))
      #endif

      // deliver to main thread
      await MainActor.run {
        self?.completionsDidUpdate(results)
      }
    }
  }

  /// Cancel the completion task
  internal func cancelCompletion() {
    _completionTask?.cancel()
    _completionTask = nil
    _lastCompletionQueryTime = .distantPast  // Prevent stale results
  }

  /// Respond to completion results
  private func completionsDidUpdate(_ results: [CommandRecord]) {
    dispatchPrecondition(condition: .onQueue(.main))

    // obtain completion items
    let items: [any CompletionItem] = results.map { record in
      let id = UUID().uuidString
      return RhCompletionItem(id: id, record)
    }
    guard !items.isEmpty else { _completionWindowController?.close(); return }

    // compute segment frame
    guard let range = documentManager.textSelection?.effectiveRange,
      range.isEmpty,
      let segmentFrame = documentManager.textSegmentFrame(in: range, type: .standard)
    else { return }

    // obtain controller
    guard let window = self.window,
      let completionWindowController = self._completionWindowController
    else { return }

    // compute top-left point of window
    let topLeftPoint = {
      let point = segmentFrame.origin
        .with(xDelta: RhCompletionItem.displayXDelta)
        .with(y: segmentFrame.maxY)
      return window.convertPoint(toScreen: contentView.convert(point, to: nil))
    }()
    // compute bottom-left point of window when top-left point is improper
    let bottomLeftPoint = topLeftPoint.with(yDelta: segmentFrame.height)  // note sign

    // show window
    completionWindowController.showWindow(
      at: topLeftPoint, bottomLeftPoint, items: items, parent: window)
    completionWindowController.delegate = self
  }
}

extension TextView: CompletionWindowDelegate {
  public func completionWindowController(
    _ windowController: CompletionWindowController, item: any CompletionItem,
    movement: NSTextMovement
  ) {
    guard let item = item as? RhCompletionItem,
      let selection = documentManager.textSelection?.effectiveRange
    else { return }

    switch item.commandRecord.content {
    case .plaintext(let string):
      let result = replaceCharactersForEdit(in: selection, with: string)
      assert(result.isInternalError == false)

    case .other(let exprs):
      let content = NodeUtils.convertExprs(exprs)
      let result = replaceContentsForEdit(in: selection, with: content)
      assert(result.isInternalError == false)
    }
  }
}
