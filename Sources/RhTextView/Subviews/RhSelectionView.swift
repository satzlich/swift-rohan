// Copyright 2024-2025 Lie Yan

import AppKit

/**
 ```
 RhSelectionView
    |---RhRegionView *
 ```
 */
final class RhSelectionView: RhView {
    var selectionColor: NSColor? = NSColor.selectedTextBackgroundColor {
        didSet {
            for subview in subviews {
                (subview as? RhRegionView)?.backgroundColor = selectionColor
            }
        }
    }

    func insertRegion(_ frame: CGRect) {
        let subview = RhRegionView(frame: frame)
        subview.backgroundColor = selectionColor
        addSubview(subview)
    }

    func clearRegions() {
        subviews.removeAll()
    }

    private final class RhRegionView: RhView { }
}
