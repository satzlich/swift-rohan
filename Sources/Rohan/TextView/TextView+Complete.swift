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

    triggerCompletion(query: "arbitrary", location: range.location)
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
    // obtain completion provider
    guard self.completionProvider != nil
    else {
      self.notifyAutoCompleteNotReady()
      return
    }
    // obtain container category
    guard let containerCategory = documentManager.containerCategory(for: location)
    else {
      Rohan.logger.debug("triggerCompletion: container category is nil")
      return
    }

    // Cancel previous task
    self.cancelCompletion()

    // record query time
    let currentQueryTime = Date()
    _lastCompletionQueryTime = currentQueryTime

    // assign new task
    _completionTask = Task { [weak self] in
      guard !Task.isCancelled else { return }

      // Debounce typing
      let debounceInterval: TimeInterval = 0.2
      try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1e9))

      guard !Task.isCancelled else { return }

      // Validate query freshness
      guard self?._lastCompletionQueryTime == currentQueryTime else { return }

      // Get results from provider
      guard let provider = self?.completionProvider else { return }
      let results = provider.getCompletions(query, containerCategory, maxResults: 10)

      try? await Task.sleep(nanoseconds: UInt64(0.8e9))  // Simulate delay

      // Deliver to main thread
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
    // TODO: compute items from results
    let items: [any CompletionItem] = Self.sampleCompletionItems()
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

    // compute completion window origin
    let origin = segmentFrame.origin
      .with(yDelta: segmentFrame.height)
      .with(xDelta: RhCompletionItem.displayXDelta)
    let windowOrigin = window.convertPoint(toScreen: contentView.convert(origin, to: nil))

    // show window
    completionWindowController.showWindow(at: windowOrigin, items: items, parent: window)
    completionWindowController.delegate = self
  }

  private static func sampleCompletionItems() -> Array<any CompletionItem> {
    let words = [
      "apple", "banana", "grape",
      "kiwi",
      "mango", "orange", "peach",
      "pear", "pine", "pineapple",
      "strawberry", "watermelon",
    ]
    return words.map { word in
      let id = UUID().uuidString
      let label = {
        let attrString = NSAttributedString(
          string: word,
          attributes: [
            .font: NSFont(name: "Monaco", size: 14)
              ?? NSFont.systemFont(ofSize: 14)
          ])
        return AttributedString(attrString)
      }()
      let symbolName = symbolName(for: word)

      return RhCompletionItem(
        id: id, label: label, symbolName: symbolName, insertText: word)
    }
  }

  private static func symbolName(for word: String) -> String {
    if let firstChar = word.first, firstChar.isASCII, firstChar.isLetter {
      return "\(firstChar.lowercased()).square"
    }
    else {
      return "note.text"
    }
  }
}

extension TextView: CompletionWindowDelegate {
  public func completionWindowController(
    _ windowController: CompletionWindowController, item: any CompletionItem,
    movement: NSTextMovement
  ) {
    guard let item = item as? RhCompletionItem else { return }
    insertText(item.insertText, replacementRange: .notFound)
  }
}
