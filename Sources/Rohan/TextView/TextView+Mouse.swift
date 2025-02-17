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
    guard
      let selection = documentManager.textSelectionNavigation.textSelection(
        interactingAt: point, anchors: [], modifiers: [], selecting: false, bounds: .infinite)
    else { return }

    if let location = selection.textRanges.first?.location {
      Rohan.logger.debug("mouseDown: \(location)")
    }

    // update text selections
    documentManager.textSelection = selection
    // reconcile selection
    reconcileSelection()
  }
}
