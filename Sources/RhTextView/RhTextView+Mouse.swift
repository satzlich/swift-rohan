// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    override public func mouseDown(with event: NSEvent) {
        // if input context has consumed event
        if inputContext?.handleEvent(event) == true {
            return
        }

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
        let point = contentView.convert(event.locationInWindow, from: nil)

        if shiftPressed {
            // extend selection
            updateTextSelection(
                interactingAt: point,
                inContainerAt: textLayoutManager.documentRange.location,
                anchors: textLayoutManager.textSelections,
                extending: true
            )
        }
        else {
            // set insertion point
            setInsertionPoint(interactingAt: point)
        }

        // reconcile selection
        reconcileSelection()

        needsDisplay = true
    }
}
