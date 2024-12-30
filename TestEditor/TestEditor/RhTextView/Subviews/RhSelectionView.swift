// Copyright 2024 Lie Yan

import AppKit

/**
 ```
 RhSelectionView
    |---RhHighlightView +
 ```
 */
final class RhSelectionView: RhView { }

final class RhHighlightView: RhView {
    var backgroundColor: NSColor? {
        didSet {
            layer?.backgroundColor = backgroundColor?.cgColor
        }
    }
}
