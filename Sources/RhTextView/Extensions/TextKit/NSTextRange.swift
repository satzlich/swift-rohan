// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextRange {
    func clamped(to textRange: NSTextRange) -> NSTextRange? {
        let location = self.location.clamped(to: textRange)
        let endLocation = self.endLocation.clamped(to: textRange)

        return NSTextRange(location: location, end: endLocation)
    }
}
