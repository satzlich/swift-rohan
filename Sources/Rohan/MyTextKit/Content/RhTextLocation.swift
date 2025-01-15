// Copyright 2024-2025 Lie Yan

import Algorithms
import Collections
import Foundation

public protocol RhTextLocation { // text location is an insertion point
    func compare(_ location: any RhTextLocation) -> ComparisonResult?
}

struct RohanTextLocation: RhTextLocation {
    var path: [RohanIndex]
    var offset: Int

    func compare(_ location: any RhTextLocation) -> ComparisonResult? {
        let rhs = location as! RohanTextLocation
        guard let comparePath = RohanTextLocation.comparePath(path, rhs.path)
        else { return nil }

        return comparePath == .orderedSame
            ? ComparableComparator().compare(offset, rhs.offset)
            : comparePath
    }

    private static func comparePath(_ lhs: [RohanIndex],
                                    _ rhs: [RohanIndex]) -> ComparisonResult?
    {
        guard let (lhs, rhs) = zip(lhs, rhs).first(where: { $0.0 != $0.1 })
        else { return ComparableComparator().compare(lhs.count, rhs.count) }

        switch (lhs, rhs) {
        case let (.arrayIndex(lhs), .arrayIndex(rhs)):
            return ComparableComparator().compare(lhs, rhs)
        case let (.mathIndex(lhs), .mathIndex(rhs)):
            return ComparableComparator().compare(lhs, rhs)
        case let (.gridIndex(lhs), .gridIndex(rhs)):
            return ComparableComparator().compare(lhs, rhs)
        case _:
            return nil
        }
    }
}
