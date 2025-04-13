// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class TextInputHandler {
  /// Handler for character input events.
  /// Returns true if the event was handled, false otherwise.
  typealias CharHandler = (TextView) -> Bool

  private let charHandlers: [Character: CharHandler] = [
    "\\": { textView in false },
    "$": { textView in false },
    "^": { textView in false },
    "_": { textView in false },
  ]

  /// Handle the key event for the text view.
  /// - Returns: true if the event was handled, false otherwise.
  func handleKeyEvent(_ event: NSEvent, textView: TextView) -> Bool {
    guard !textView.hasMarkedText(),
      let char = event.characters?.first,
      let handler = charHandlers[char]
    else { return false }

    return handler(textView)
  }
}
