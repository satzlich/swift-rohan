// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextContentManager {
    func characterRange(for textRange: NSTextRange) -> NSRange {
        let location = characterIndex(for: textRange.location)
        let length = offset(from: textRange.location, to: textRange.endLocation)
        return NSRange(location: location, length: length)
    }

    func characterIndex(for textLocation: any NSTextLocation) -> Int {
        offset(from: documentRange.location, to: textLocation)
    }

    func textRange(for characterRange: NSRange) -> NSTextRange? {
        guard let location = textLocation(for: characterRange.location) else {
            return nil
        }
        let end = self.location(location, offsetBy: characterRange.length)
        return NSTextRange(location: location, end: end)
    }

    func textLocation(for characterIndex: Int) -> NSTextLocation? {
        location(documentRange.location, offsetBy: characterIndex)
    }
}
