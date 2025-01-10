// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextContentManager {
    /**
     Convert text range to character range
     */
    public func characterRange(for textRange: NSTextRange) -> NSRange {
        let location = characterIndex(for: textRange.location)
        let length = offset(from: textRange.location, to: textRange.endLocation)
        return NSRange(location: location, length: length)
    }

    /**
     Convert text location to character index
     */
    public func characterIndex(for textLocation: any NSTextLocation) -> Int {
        offset(from: documentRange.location, to: textLocation)
    }

    /**
     Convert character range to text range
     */
    public func textRange(for characterRange: NSRange) -> NSTextRange? {
        guard let location = textLocation(for: characterRange.location) else {
            return nil
        }
        let end = self.location(location, offsetBy: characterRange.length)
        return NSTextRange(location: location, end: end)
    }

    /**
     Convert character index to text location
     */
    public func textLocation(for characterIndex: Int) -> NSTextLocation? {
        location(documentRange.location, offsetBy: characterIndex)
    }
}
