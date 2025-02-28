// Copyright 2025 Lie Yan

import AppKit
import Foundation

extension TextView {
  override public func mouseDown(with event: NSEvent) {
    // if input context has consumed event, return
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

    if shiftPressed {
      // TODO: extend selection

    }
    else {
      let selection = documentManager.textSelectionNavigation.textSelection(
        interactingAt: point, anchors: nil,
        modifiers: [], selecting: false, bounds: .infinite)
      guard let selection else { return }
      // update text selections
      documentManager.textSelection = selection
      // reconcile selection
      reconcileSelection()
    }
  }

  override public func mouseUp(with event: NSEvent) {
    // if input context has consumed event, return
    if inputContext?.handleEvent(event) == true { return }
    // forward event
    super.mouseUp(with: event)
  }

  override public func mouseMoved(with event: NSEvent) {
    // if input context has consumed event, return
    if inputContext?.handleEvent(event) == true { return }
    // forward event
    super.mouseMoved(with: event)
  }
}
