// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    func updateTextSelection(
        interactingAt point: CGPoint,
        inContainerAt location: NSTextLocation,
        anchors: [NSTextSelection] = [],
        extending: Bool,
        isDragging: Bool = false,
        visual: Bool = false
    ) {
        var modifiers: NSTextSelectionNavigation.Modifier = []
        if extending {
            modifiers.insert(.extend)
        }
        if visual {
            modifiers.insert(.visual)
        }

        let selections = textLayoutManager.textSelectionNavigation
            .textSelections(
                interactingAt: point,
                inContainerAt: location,
                anchors: anchors,
                modifiers: modifiers,
                selecting: isDragging,
                bounds: textLayoutManager.usageBoundsForTextContainer
            )

        if !selections.isEmpty {
            textLayoutManager.textSelections = selections
        }
    }

    func setInsertionPoint(interactingAt point: CGPoint) {
        textLayoutManager.setInsertionPoint(interactingAt: point)
    }
}
