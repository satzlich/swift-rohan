// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

final class RhInsertionIndicatorView: RhView {
    func addInsertionIndicator(_ frame: CGRect) {
        let subview = NSTextInsertionIndicator(frame: frame)
        addSubview(subview)
    }

    func clearInsertionIndicators() {
        subviews.removeAll()
    }
}
