// Copyright 2024 Lie Yan

import Algorithms
import AppKit
import Foundation

extension RhTextView {
    /**
     Reconcile the selection view and insertion point indicators with the
     current selection.
     */
    func reconcileSelection() {
        // Ensure (a) there is a selection and (b) there is a viewport.
        guard !textLayoutManager.textSelections.isEmpty,
              let viewportRange = textLayoutManager.textViewportLayoutController.viewportRange
        else {
            selectionView.clearSelectedRegion()
            clearTextInsertionIndicators()
            return
        }

        // partition ranges into region and point ranges
        let textRanges = textLayoutManager.textSelections
            .flatMap(\.textRanges)
            .sorted(by: { $0.location < $1.location })
        let (regionRanges, pointRanges) = textRanges.partitioned(by: \.isEmpty)

        if !regionRanges.isEmpty {
            // clamp region ranges to viewport (for better performance)
            let visibleRanges = regionRanges.compactMap { $0.clamped(to: viewportRange) }

            // when there are region ranges, clear the insertion indicators
            clearTextInsertionIndicators()
            reconcileSelectionView(visibleRanges)
        }
        else {
            // when there are no region ranges, clear the selection
            selectionView.clearSelectedRegion()
            reconcileTextInsertionIndicators(pointRanges)
        }
    }

    /**
     Reconcile the selection view with the given text ranges.
     */
    func reconcileSelectionView(_ textRanges: [NSTextRange]) {
        selectionView.clearSelectedRegion()

        for textRange in textRanges {
            textLayoutManager.enumerateTextSegments(
                in: textRange,
                type: .selection,
                options: .rangeNotRequired
            ) { _, segmentFrame, _, _ in
                let segmentFrame = segmentFrame.intersection(frame)
                guard !segmentFrame.isNull else {
                    return true
                }

                if segmentFrame.width != 0 {
                    selectionView.insertSelectedRegion(segmentFrame)
                }
                return true // keep going
            }
        }
    }

    /**
     Reconcile the text insertion indicators with the insertion points.
     */
    func reconcileTextInsertionIndicators(_ insertionPoints: [NSTextRange]) {
        clearTextInsertionIndicators()

        for insertionPoint in insertionPoints {
            textLayoutManager.enumerateTextSegments(
                in: insertionPoint,
                type: .standard
            ) { segmentRange, segmentFrame, _, _ in
                guard segmentRange != nil else {
                    return true
                }

                addSubview(RhTextInsertionIndicator(frame: segmentFrame))
                return false // stop
            }
        }
    }

    func clearTextInsertionIndicators() {
        subviews.removeAll {
            $0 is RhTextInsertionIndicator
        }
    }

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
