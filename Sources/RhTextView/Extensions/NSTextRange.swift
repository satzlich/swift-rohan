// Copyright 2024 Lie Yan

import AppKit
import Foundation

extension NSTextRange {
    func clamped(to textRange: NSTextRange) -> NSTextRange? {
        let location = self.location.clamped(to: textRange)
        let endLocation = self.endLocation.clamped(to: textRange)

        return .init(location: location, end: endLocation)
    }
}
