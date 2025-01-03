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
        // clear the selection view
        clearSelectionHighlight()
        // clear the insertion point indicators
        clearTextInsertionIndicators()

        // Ensure (a) there is a selection and (b) there is a viewport.
        guard !textLayoutManager.textSelections.isEmpty,
              let viewportRange = textLayoutManager.textViewportLayoutController.viewportRange
        else {
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
            insertSelectionHighlight(for: visibleRanges)
        }
        else {
            insertTextInsertionIndicators(for: pointRanges)
        }
    }

    /**
     Reconcile the selection view with the given text ranges.
     */
    private func insertSelectionHighlight(for textRanges: [NSTextRange]) {
        // for each segment in the text range, insert the frame if it's visible
        for textRange in textRanges {
            textLayoutManager.enumerateTextSegments(in: textRange,
                                                    type: .selection,
                                                    options: .rangeNotRequired)
            { (_, segmentFrame, _, _) in

                let segmentFrame = segmentFrame.intersection(frame)
                if !segmentFrame.isEmpty {
                    selectionView.addHighlightRegion(segmentFrame)
                }
                return true // keep going
            }
        }
    }

    private func clearSelectionHighlight() {
        selectionView.clearHighlightRegions()
    }

    /**
     Insert the text insertion indicators for the insertion points.
     */
    private func insertTextInsertionIndicators(for insertionPoints: [NSTextRange]) {
        // for each segment in the text range, insert the frame if it's valid
        for insertionPoint in insertionPoints {
            textLayoutManager.enumerateTextSegments(in: insertionPoint,
                                                    type: .standard)
            { (segmentRange, segmentFrame, _, _) in

                guard segmentRange != nil else { return true }
                insertionIndicatorView.addInsertionIndicator(segmentFrame)
                return false // stop
            }
        }
    }

    private func clearTextInsertionIndicators() {
        insertionIndicatorView.clearInsertionIndicators()
    }
}
