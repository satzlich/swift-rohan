// Copyright 2024-2025 Lie Yan

import Foundation

/**
 Text range.

 - Note: "Rh" for "Rohan" to avoid name conflict with ``TextRange``.
 */
@frozen
public struct RhTextRange {
    public let location: RohanTextLocation
    public let endLocation: RohanTextLocation

    public var isEmpty: Bool { location.compare(endLocation) == .orderedSame }

    public init(location: RohanTextLocation) {
        self.location = location
        self.endLocation = location
    }

    public init?(location: RohanTextLocation, end: RohanTextLocation) {
        guard location.compare(end) != .orderedDescending
        else { return nil }

        self.location = location
        self.endLocation = end
    }
}
