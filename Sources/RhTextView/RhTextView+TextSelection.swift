// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension RhTextView {
    // MARK: - Key

    func updateTextSelections(
        direction: NSTextSelectionNavigation.Direction,
        destination: NSTextSelectionNavigation.Destination,
        extending: Bool,
        confined: Bool
    ) {
        textLayoutManager.textSelections =
            textLayoutManager.textSelections.compactMap { textSelection in
                textLayoutManager.textSelectionNavigation
                    .destinationSelection(for: textSelection,
                                          direction: direction,
                                          destination: destination,
                                          extending: extending,
                                          confined: confined)
            }
    }

    // MARK: - Mouse

    func updateTextSelection(
        interactingAt point: CGPoint,
        inContainerAt containerLocation: NSTextLocation,
        anchors: [NSTextSelection] = [],
        extending: Bool,
        selecting: Bool = false,
        visual: Bool = false
    ) {
        var modifiers: NSTextSelectionNavigation.Modifier = []
        if extending {
            modifiers.insert(.extend)
        }
        if visual {
            modifiers.insert(.visual)
        }

        textLayoutManager.textSelectionNavigation
            .textSelections(
                interactingAt: point,
                inContainerAt: containerLocation,
                anchors: anchors,
                modifiers: modifiers,
                selecting: selecting,
                bounds: textLayoutManager.usageBoundsForTextContainer
            )
            .require { !$0.isEmpty }
            .map { textLayoutManager.textSelections = $0 }
    }

    func setInsertionPoint(interactingAt point: CGPoint) {
        textLayoutManager.setInsertionPoint(interactingAt: point)
    }
}
