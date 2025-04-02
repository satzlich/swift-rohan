// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public override func complete(_ sender: Any?) {
    Rohan.logger.debug("complete")
    performCompletion()
  }

  /// Close completion window
  public func cancelComplete(_ sender: Any?) {
    Rohan.logger.debug("cancelComplete")
    completionWindowController?.close()
  }

  public override func cancelOperation(_ sender: Any?) {
    Rohan.logger.debug("cancelOepration")

    if let completionWindowController, completionWindowController.isVisible {
      completionWindowController.close()
    }
    else {
      self.complete(sender)
    }
  }

  // MARK: - Private

  private func performCompletion() {
    dispatchPrecondition(condition: .onQueue(.main))

    // obtain completion items
    let completionItems: [any CompletionItem] = Self.sampleCompletionItems()
    guard completionItems.isEmpty == false
    else { completionWindowController?.close(); return }

    // compute segment frame
    guard let range = documentManager.textSelection?.effectiveRange,
      range.isEmpty,
      let segmentFrame = documentManager.textSegmentFrame(in: range, type: .standard)
    else { return }

    // obtain controller
    guard let window = self.window,
      let completionWindowController = self.completionWindowController
    else { return }

    // compute origin
    let origin = segmentFrame.origin
      .with(yDelta: segmentFrame.height)
      .with(xDelta: -14)  // arbitrary shift
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
      let label = NSAttributedString(string: word)
      let symbolName = symbolName(for: word)
      return RhCompletionItem(
        id: UUID().uuidString, label: label, symbolName: symbolName, insertText: word)
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
