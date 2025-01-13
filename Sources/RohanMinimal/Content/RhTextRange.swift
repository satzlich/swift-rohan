// Copyright 2024-2025 Lie Yan

import Foundation

@frozen
public struct RhTextRange {
    public let location: any RhTextLocation
    public let endLocation: any RhTextLocation

    public var isEmpty: Bool { location.compare(endLocation) == .orderedSame }

    public init(location: any RhTextLocation) {
        self.location = location
        self.endLocation = location
    }

    public init?(location: any RhTextLocation, end: (any RhTextLocation)) {
        guard let result = location.compare(end),
              result != .orderedDescending
        else { return nil }

        self.location = location
        self.endLocation = end
    }
}
