// Copyright 2024 Lie Yan

import AppKit
import Foundation

extension NSTextLocation {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) == .orderedSame
    }

    static func != (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) != .orderedSame
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) == .orderedAscending
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) != .orderedDescending
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) == .orderedDescending
    }

    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.compare(rhs) != .orderedAscending
    }

    func clamped(to textRange: NSTextRange) -> any NSTextLocation {
        if self <= textRange.location {
            return textRange.location
        }
        if self >= textRange.endLocation {
            return textRange.endLocation
        }
        return self
    }
}
