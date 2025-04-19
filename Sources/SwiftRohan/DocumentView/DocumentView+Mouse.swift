// Copyright 2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  override public func mouseDown(with event: NSEvent) {
    // if input context has consumed event, return
    if inputContext?.handleEvent(event) == true { return }

    // ensure we are processing single left click
    guard event.type == .leftMouseDown,
      event.clickCount == 1
    else {  // otherwise, forward event
      super.mouseDown(with: event)
      return
    }

    // determine if we are selecting, that is, shift key is pressed
    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    let selecting = modifierFlags.contains(.shift)
    // convert cursor point to coordinate in content view
    let point: CGPoint = contentView.convert(event.locationInWindow, from: nil)
    // resolve text selection
    guard
      let selection = documentManager.textSelectionNavigation.textSelection(
        interactingAt: point,
        anchors: documentManager.textSelection,
        modifiers: [],
        selecting: selecting,
        bounds: .infinite)
    else { return }
    // update selection
    documentManager.textSelection = selection
    self.setNeedsUpdate(selection: true)
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

  public override func mouseDragged(with event: NSEvent) {
    // if input context has consumed event
    if inputContext?.handleEvent(event) == true { return }

    // ensure there is a movement
    guard event.deltaX != 0 || event.deltaY != 0
    else {
      // otherwise, forward event
      super.mouseDragged(with: event)
      return
    }

    // convert cursor point to coordinate in content view
    let point = contentView.convert(event.locationInWindow, from: nil)

    // resolve text selection
    let selection = documentManager.textSelectionNavigation.textSelection(
      interactingAt: point, anchors: documentManager.textSelection,
      modifiers: [], selecting: true, bounds: .infinite)
    guard let selection else { return }
    // update selection
    documentManager.textSelection = selection
    self.setNeedsUpdate(selection: true, scroll: true)
  }
}
