// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSTextContentManager {
    /**
     Convert text range to character range
     */
    func characterRange(for textRange: NSTextRange) -> NSRange {
        let location = characterIndex(for: textRange.location)
        let length = offset(from: textRange.location, to: textRange.endLocation)
        return NSRange(location: location, length: length)
    }

    /**
     Convert text location to character index
     */
    func characterIndex(for textLocation: any NSTextLocation) -> Int {
        offset(from: documentRange.location, to: textLocation)
    }

    /**
     Convert character range to text range
     */
    func textRange(for characterRange: NSRange) -> NSTextRange? {
        guard let location = textLocation(for: characterRange.location) else {
            return nil
        }
        let end = self.location(location, offsetBy: characterRange.length)
        return NSTextRange(location: location, end: end)
    }

    /**
     Convert character index to text location
     */
    func textLocation(for characterIndex: Int) -> NSTextLocation? {
        location(documentRange.location, offsetBy: characterIndex)
    }

    /**
     Replace text in multiple ranges
     */
    func replaceContents(in ranges: [NSTextRange],
                         with textElements: [NSTextElement]?)
    {
        let ranges = ranges.sorted(by: { $0.location > $1.location })
        for range in ranges {
            replaceContents(in: range, with: textElements)
        }
    }
}
