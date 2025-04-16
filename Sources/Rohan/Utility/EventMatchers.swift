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
}
