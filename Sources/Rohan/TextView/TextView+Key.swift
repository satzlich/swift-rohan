// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  override public func keyDown(with event: NSEvent) {
    // hide cursor
    NSCursor.setHiddenUntilMouseMoves(true)
    // if input context has consumed event, return
    if inputContext?.handleEvent(event) == true { return }
    // forward event
    interpretKeyEvents([event])
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
