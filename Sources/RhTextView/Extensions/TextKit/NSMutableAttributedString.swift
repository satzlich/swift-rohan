// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSMutableAttributedString {
    func performEditing(_ closure: () -> Void) {
        beginEditing()
        closure()
        endEditing()
    }
}
