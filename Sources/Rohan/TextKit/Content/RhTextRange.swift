// Copyright 2024-2025 Lie Yan

import Foundation

/**
 Text range.

 - Note: "Rh" for "Rohan" to avoid name conflict with ``TextRange``.
 */
@frozen
public struct RhTextRange {
    public let location: any TextLocation
    public let endLocation: any TextLocation

    public var isEmpty: Bool { location.compare(endLocation) == .orderedSame }

    public init(location: any TextLocation) {
        self.location = location
        self.endLocation = location
    }

    public init?(location: any TextLocation, end: any TextLocation) {
        guard location.compare(end) != .orderedDescending
        else { return nil }

        self.location = location
        self.endLocation = end
    }
}
