// Copyright 2024-2025 Lie Yan

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
            clearSelectedRegions()
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

            // clear the insertion point indicators
            clearTextInsertionIndicators()
            // reconcile the selection view
            reconcileSelectedRegions(visibleRanges)
        }
        else {
            // clear the selection view
            clearSelectedRegions()
            // reconcile the insertion point indicators
            reconcileTextInsertionIndicators(pointRanges)
        }
    }

    /**
     Reconcile the selection view with the given text ranges.
     */
    private func reconcileSelectedRegions(_ textRanges: [NSTextRange]) {
        clearSelectedRegions()

        // for each segment in the text range, insert the frame if it's visible

        for textRange in textRanges {
            textLayoutManager.enumerateTextSegments(
                in: textRange,
                type: .selection,
                options: .rangeNotRequired
            ) { _, segmentFrame, _, _ in

                let segmentFrame = segmentFrame.intersection(frame)
                if !segmentFrame.isEmpty {
                    insertSelectedRegion(segmentFrame)
                }
                return true // keep going
            }
        }
    }

    private func insertSelectedRegion(_ rect: NSRect) {
        selectionView.insertRegion(rect)
    }

    private func clearSelectedRegions() {
        selectionView.clearRegions()
    }

    /**
     Reconcile the text insertion indicators with the insertion points.
     */
    private func reconcileTextInsertionIndicators(_ insertionPoints: [NSTextRange]) {
        clearTextInsertionIndicators()

        // for each segment in the text range, insert the frame if it's valid

        for insertionPoint in insertionPoints {
            textLayoutManager.enumerateTextSegments(
                in: insertionPoint,
                type: .standard
            ) { segmentRange, segmentFrame, _, _ in

                guard segmentRange != nil else { return true }
                insertTextInsertionIndicator(segmentFrame)
                return false // stop
            }
        }
    }

    private func insertTextInsertionIndicator(_ rect: NSRect) {
        addSubview(RhTextInsertionIndicator(frame: rect))
    }

    private func clearTextInsertionIndicators() {
        subviews.removeAll(where: { $0 is RhTextInsertionIndicator })
    }
}
