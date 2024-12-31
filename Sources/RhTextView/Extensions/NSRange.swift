// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSRange {
    /**
     The range that indicates that no range was found.
     */
    static let notFound = NSRange(location: NSNotFound, length: 0)

    func clamped(to range: NSRange) -> NSRange {
        if self.location == NSNotFound || range.location == NSNotFound {
            return NSRange.notFound
        }
        let location = Swift.max(location, range.location)
        let end = Swift.min(location + length, range.location + range.length)
        return NSRange(location: location, length: end - location)
    }
}
