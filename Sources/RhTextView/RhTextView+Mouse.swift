// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
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
    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

    // convert to content view coordinate
    let point = contentView.convert(event.locationInWindow, from: nil)

    if modifierFlags.contains(.shift) {
      // extend selection
      updateTextSelection(
        interactingAt: point,
        inContainerAt: textLayoutManager.documentRange.location,
        anchors: textLayoutManager.textSelections,
        extending: true
      )
      // reconcile selection
      reconcileSelection()
    }
    else {
      // set insertion point
      setInsertionPoint(interactingAt: point)
      // reconcile selection
      reconcileSelection()
    }
  }

  override public func mouseUp(with event: NSEvent) {
    // if input context has consumed event
    if inputContext?.handleEvent(event) == true { return }

    super.mouseUp(with: event)
  }

  override public func mouseMoved(with event: NSEvent) {
    // if input context has consumed event
    if inputContext?.handleEvent(event) == true { return }

    super.mouseMoved(with: event)
  }

  override public func mouseDragged(with event: NSEvent) {
    // if input context has consumed event
    if inputContext?.handleEvent(event) == true { return }

    // there must be a movement
    guard event.deltaX != 0 || event.deltaY != 0 else {
      super.mouseDragged(with: event)
      return
    }

    // convert to content view coordinate
    let point = contentView.convert(event.locationInWindow, from: nil)

    // update text selection
    updateTextSelection(
      interactingAt: point,
      inContainerAt: textLayoutManager.documentRange.location,
      anchors: textLayoutManager.textSelections,
      extending: true,
      selecting: true
    )

    // reconcile selection
    reconcileSelection()
  }
}
