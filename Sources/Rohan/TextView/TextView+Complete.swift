// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public override func complete(_ sender: Any?) {
    Rohan.logger.debug("complete")
    performCompletion()
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

  func completionsDidUpdate(_ results: [_CompletionResult]) {
    // TODO: show completion results
  }

  func triggerCompletion(query: String) {
    // Cancel previous task
    _completionTask?.cancel()

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
      let results = provider.provideCompletions(for: query, maxResults: 10)

      // Deliver to main thread
      await MainActor.run {
        self?.completionsDidUpdate(results)
      }
    }
  }

  private func performCompletion() {
    dispatchPrecondition(condition: .onQueue(.main))

    // obtain completion items
    let completionItems: [any CompletionItem] = Self.sampleCompletionItems()
    guard completionItems.isEmpty == false
    else { _completionWindowController?.close(); return }

    // compute segment frame
    guard let range = documentManager.textSelection?.effectiveRange,
      range.isEmpty,
      let segmentFrame = documentManager.textSegmentFrame(in: range, type: .standard)
    else { return }

    // obtain controller
    guard let window = self.window,
      let completionWindowController = self._completionWindowController
    else { return }

    // compute origin
    let origin = segmentFrame.origin
      .with(yDelta: segmentFrame.height)
      .with(xDelta: RhCompletionItem.displayXDelta)
    let completionWindowOrigin =
      window.convertPoint(toScreen: contentView.convert(origin, to: nil))

    // show window
    completionWindowController.showWindow(
      at: completionWindowOrigin, items: completionItems, parent: window)
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
