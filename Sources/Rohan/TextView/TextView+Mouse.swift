// Copyright 2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  override public func mouseDown(with event: NSEvent) {
    // if input context has consumed event
    if inputContext?.handleEvent(event) == true { return }

    // guard single left click
    guard event.type == .leftMouseDown,
      event.clickCount == 1
    else {
      super.mouseDown(with: event)
      return
    }

    // get modifier keys
    let shiftPressed = event.modifierFlags.contains(.shift)

    // convert to content view coordinate
    let point: CGPoint = contentView.convert(event.locationInWindow, from: nil)

    if let location = documentManager.getTextLocation(interactingAt: point) {
      Rohan.logger.debug("point: \(point.formatted(3))")
      Rohan.logger.debug("location: \(location.description)")
    }
    else {
      Rohan.logger.debug("not found")
    }

    if shiftPressed {
      // extend selection
    }
    else {
      // set insertion point
    }
  }
}
