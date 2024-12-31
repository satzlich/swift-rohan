// Copyright 2024 Lie Yan

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
}
