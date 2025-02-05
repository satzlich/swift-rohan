// Copyright 2024-2025 Lie Yan

import Foundation

public protocol TextLocation { // text location is an insertion point
    func compare(_ location: any TextLocation) -> ComparisonResult
}

struct RohanTextLocation: TextLocation, CustomStringConvertible {
    var path: [RohanIndex]
    var offset: Int

    internal init(_ path: [RohanIndex], _ offset: Int? = nil) {
        self.path = path
        self.offset = offset ?? 0
    }

    public func compare(_ location: any TextLocation) -> ComparisonResult {
        func comparePath(_ lhs: [RohanIndex], _ rhs: [RohanIndex]) -> ComparisonResult {
            guard let (lhs, rhs) = zip(lhs, rhs).first(where: { $0.0 != $0.1 })
            else { return ComparableComparator().compare(lhs.count, rhs.count) }

            switch (lhs, rhs) {
            case let (.contentOffset(lhs), .contentOffset(rhs)):
                return ComparableComparator().compare(lhs, rhs)
            case let (.nodeIndex(lhs), .nodeIndex(rhs)):
                return ComparableComparator().compare(lhs, rhs)
            case let (.mathIndex(lhs), .mathIndex(rhs)):
                return ComparableComparator().compare(lhs, rhs)
            case let (.gridIndex(lhs), .gridIndex(rhs)):
                return ComparableComparator().compare(lhs, rhs)
            case _:
                preconditionFailure("not supported")
            }
        }

        let rhs = location as! RohanTextLocation
        let comparePath = comparePath(path, rhs.path)

        return comparePath == .orderedSame
            ? ComparableComparator().compare(offset, rhs.offset)
            : comparePath
    }

    var description: String {
        return "[" + path.map(\.description).joined(separator: ",") + "]:\(offset)"
    }
}
