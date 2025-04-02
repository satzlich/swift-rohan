// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  public override func complete(_ sender: Any?) {
    performCompletion()
  }

  /// Close completion window
  public func cancelComplete(_ sender: Any?) {
    completionWindowController?.close()
  }

  public override func cancelOperation(_ sender: Any?) {
    if let completionWindowController, completionWindowController.isVisible {
      completionWindowController.close()
    }
    else {
      self.complete(sender)
    }
  }

  // MARK: - Private

  @MainActor
  private func performCompletion() {
    dispatchPrecondition(condition: .onQueue(.main))

    let completionItems: [any CompletionItem] = Self.sampleCompletionItems()
    guard completionItems.isEmpty == false
    else { completionWindowController?.close(); return }

    guard let window = self.window,
      let completionWindowController = self.completionWindowController
    else { return }

    let origin = CGPoint(x: 10, y: 10)
    let completionWindowOrigin =
      window.convertPoint(toScreen: contentView.convert(origin, to: nil))
    completionWindowController.showWindow(
      at: completionWindowOrigin, items: completionItems, parent: window)
    completionWindowController.delegate = self
  }

  private static func sampleCompletionItems() -> Array<any CompletionItem> {
    let words = ["apple", "banana", "orange", "pine", "pineapple"]
    return words.map { word in
      let id = UUID().uuidString
      let label = word.localizedCapitalized
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

  }
}
