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
}
