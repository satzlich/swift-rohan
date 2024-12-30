// Copyright 2024 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    override public func mouseDown(with event: NSEvent) {
        // ensure input context has not consumed event
        if inputContext?.handleEvent(event) == true {
            return
        }

        // ensure single left click
        guard event.type == .leftMouseDown,
              event.clickCount == 1
        else {
            super.mouseDown(with: event)
            return
        }

        // get modifier keys
        let isShiftPressed =
            event.modifierFlags
                .intersection(.deviceIndependentFlagsMask)
                .contains(.shift)

        let point = contentView.convert(event.locationInWindow, from: nil)
        if isShiftPressed {
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
