// Copyright 2024-2025 Lie Yan

import Algorithms
import Collections
import Foundation

public protocol RhTextLocation { // text location is an insertion point
    func compare(_ location: any RhTextLocation) -> ComparisonResult
}

struct RohanTextLocation: RhTextLocation, CustomStringConvertible {
    var path: [RohanIndex]
    var offset: Int?

    internal init(path: [RohanIndex], offset: Int? = nil) {
        self.path = path
        self.offset = offset
    }

    public func compare(_ location: any RhTextLocation) -> ComparisonResult {
        func comparePath(_ lhs: [RohanIndex], _ rhs: [RohanIndex]) -> ComparisonResult {
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
                preconditionFailure("not supported")
            }
        }

        func compareOffset(_ lhs: Int?, _ rhs: Int?) -> ComparisonResult {
            switch (lhs, rhs) {
            case (.none, .none):
                return .orderedSame
            case (.none, .some):
                return .orderedAscending
            case (.some, .none):
                return .orderedDescending
            case let (.some(lhs), .some(rhs)):
                return ComparableComparator().compare(lhs, rhs)
            }
        }

        let rhs = location as! RohanTextLocation
        let comparePath = comparePath(path, rhs.path)

        return comparePath == .orderedSame
            ? compareOffset(offset, rhs.offset)
            : comparePath
    }

    var description: String {
        "[" +
            path.map(\.description).joined(separator: ",") +
            "]:\(offset != nil ? String(offset!) : "nil")"
    }

    internal func getFullPath() -> [RohanIndex] {
        offset != nil
            ? path + [.arrayIndex(offset!)]
            : path
    }
}
