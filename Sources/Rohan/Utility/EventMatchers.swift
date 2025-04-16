// Copyright 2024-2025 Lie Yan

import AppKit

enum EventMatchers {
  static func isControlSpace(_ event: NSEvent) -> Bool {
    event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .control
      && event.charactersIgnoringModifiers == " "
  }

  static func isEscape(_ event: NSEvent) -> Bool {
    event.keyCode == 53
  }

  static func isChar(_ char: Character, _ event: NSEvent) -> Bool {
    // if modifiers is clear and char is matched
    if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == [] {
      return event.charactersIgnoringModifiers == String(char)
    }
    return false
  }
}
