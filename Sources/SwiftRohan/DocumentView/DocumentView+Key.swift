// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  override public func keyDown(with event: NSEvent) {
    NSCursor.setHiddenUntilMouseMoves(true)

    // intercept trigger character
    if let triggerKey = triggerKey,
      EventMatchers.isChar(triggerKey, event)
    {
      self.complete(self)
    }
    else {
      // if input context has consumed event, return
      if inputContext?.handleEvent(event) == true { return }
      // forward event
      interpretKeyEvents([event])
    }
  }

  public override func performKeyEquivalent(with event: NSEvent) -> Bool {
    // ^Space -> complete:
    if EventMatchers.isControlSpace(event) {
      doCommand(by: #selector(NSStandardKeyBindingResponding.complete(_:)))
      return true
    }
    return super.performKeyEquivalent(with: event)
  }
}
