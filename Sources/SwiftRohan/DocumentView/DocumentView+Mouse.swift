// Copyright 2025 Lie Yan

import AppKit
import Foundation

extension DocumentView {
  override public func mouseDown(with event: NSEvent) {
    // if input context has consumed event, return
    if inputContext?.handleEvent(event) == true { return }

    if event.type == .leftMouseDown && event.clickCount == 1 {
      let selecting = event.modifierFlags
        .intersection(.deviceIndependentFlagsMask)
        .contains(.shift)

      let point: CGPoint = contentView.convert(event.locationInWindow, from: nil)

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
      documentSelectionDidChange()
    }
    else if event.type == .leftMouseDown && event.clickCount == 2 {
      let navigation = documentManager.textSelectionNavigation

      let point: CGPoint = contentView.convert(event.locationInWindow, from: nil)
      guard
        let selection = navigation.textSelection(
          interactingAt: point,
          anchors: documentManager.textSelection,
          modifiers: [],
          selecting: false,
          bounds: .infinite),
        let destination = navigation.textSelection(for: .word, enclosing: selection)
      else { return }

      // update selection
      documentManager.textSelection = destination
      documentSelectionDidChange()
    }
    else {
      super.mouseDown(with: event)
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
    guard
      let selection = documentManager.textSelectionNavigation.textSelection(
        interactingAt: point, anchors: documentManager.textSelection,
        modifiers: [], selecting: true, bounds: .infinite)
    else { return }

    // update selection
    documentManager.textSelection = selection
    documentSelectionDidChange()
  }
}
