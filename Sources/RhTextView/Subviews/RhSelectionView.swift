// Copyright 2024-2025 Lie Yan

import AppKit

/**
 ```
 RhSelectionView
    |---RhHighlightView *
 ```
 */
final class RhSelectionView: RhView {
    var selectionColor: NSColor? = NSColor.selectedTextBackgroundColor {
        didSet {
            for subview in subviews {
                (subview as? RhView)?.backgroundColor = selectionColor
            }
        }
    }

    func addHighlightRegion(_ frame: CGRect) {
        let subview = RhView(frame: frame)
        subview.backgroundColor = selectionColor
        addSubview(subview)
    }

    func clearHighlightRegions() {
        subviews.removeAll()
    }
}
