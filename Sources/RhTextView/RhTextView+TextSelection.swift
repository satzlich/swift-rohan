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
        selecting: Bool = false
    ) {
        let modifiers = extending ? NSTextSelectionNavigation.Modifier.extend : []

        let textSelections = textLayoutManager.textSelectionNavigation
            .textSelections(
                interactingAt: point,
                inContainerAt: containerLocation,
                anchors: anchors,
                modifiers: modifiers,
                selecting: selecting,
                bounds: textLayoutManager.usageBoundsForTextContainer
            )
        guard !textSelections.isEmpty else { return }
        textLayoutManager.textSelections = textSelections
    }

    func setInsertionPoint(interactingAt point: CGPoint) {
        let textSelections = textLayoutManager.textSelectionNavigation.textSelections(
            interactingAt: point,
            inContainerAt: textLayoutManager.documentRange.location,
            anchors: [],
            modifiers: [],
            selecting: false,
            bounds: textLayoutManager.usageBoundsForTextContainer
        )
        guard !textSelections.isEmpty else { return }
        textLayoutManager.textSelections = textSelections
    }
}
