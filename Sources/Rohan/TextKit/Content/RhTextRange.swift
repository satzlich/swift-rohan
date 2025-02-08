// Copyright 2024-2025 Lie Yan

import Foundation

/**
 Text range.

 - Note: "Rh" for "Rohan" to avoid name conflict with ``TextRange``.
 */
@frozen
public struct RhTextRange: Equatable, Hashable {
    public let location: TextLocation
    public let endLocation: TextLocation

    public var isEmpty: Bool { location.compare(endLocation) == .orderedSame }

    public init(location: TextLocation) {
        self.location = location
        self.endLocation = location
    }

    public init?(location: TextLocation, end: TextLocation) {
        guard let comparisonResult = location.compare(end),
              comparisonResult != .orderedDescending
        else { return nil }

        self.location = location
        self.endLocation = end
    }

    func with(location: TextLocation) -> RhTextRange? {
        RhTextRange(location: location, end: endLocation)
    }

    func with(end: TextLocation) -> RhTextRange? {
        RhTextRange(location: location, end: end)
    }

    public static func == (lhs: RhTextRange, rhs: RhTextRange) -> Bool {
        lhs.location == rhs.location && lhs.endLocation == rhs.endLocation
    }
}
