// Copyright 2024 Lie Yan

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

    func insertSelectedRegion(_ frame: CGRect) {
        let subview = RhView(frame: frame)
        subview.backgroundColor = selectionColor
        addSubview(subview)
    }

    func clearSelectedRegion() {
        subviews.removeAll()
    }
}
