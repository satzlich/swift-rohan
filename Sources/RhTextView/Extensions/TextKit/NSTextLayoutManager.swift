// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextLayoutManager {
    func setInsertionPoint(interactingAt point: CGPoint) {
        textSelections = textSelectionNavigation.textSelections(
            interactingAt: point,
            inContainerAt: documentRange.location,
            anchors: [],
            modifiers: [],
            selecting: false,
            bounds: usageBoundsForTextContainer
        )
    }

    func location(
        interactingAt point: CGPoint,
        inContainerAt containerLocation: NSTextLocation
    ) -> NSTextLocation? {
        // obtain the range for the line at the given point
        guard let lineFragmentRange = lineFragmentRange(for: point,
                                                        inContainerAt: containerLocation)
        else {
            return nil
        }

        // search for the location that minimises the distance from point.x

        var minDist = CGFloat.infinity // current minimun distance from point.x
        var caretLocation: NSTextLocation? // location for minDist

        enumerateCaretOffsetsInLineFragment(at: lineFragmentRange.location) {
            (caretOffset, location, leadingEdge, stop) in

            guard leadingEdge else {
                return
            }

            let xDist = abs(caretOffset - point.x)
            if xDist < minDist { // when moving towards `point`, update
                minDist = xDist
                caretLocation = location
            }
            else if xDist > minDist { // when moving away from `point`, stop
                stop.pointee = true
            }
        }
        return caretLocation
    }
}
