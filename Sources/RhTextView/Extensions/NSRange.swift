// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

extension NSRange {
    public func clamped(to range: NSRange) -> NSRange {
        if location == NSNotFound || range.location == NSNotFound {
            return NSRange(location: NSNotFound, length: 0)
        }
        let location_ = Swift.max(location, range.location)
        let end_ = Swift.min(location + length, range.location + range.length)
        return NSRange(location: location_, length: end_ - location_)
    }
}
