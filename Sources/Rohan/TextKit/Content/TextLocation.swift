// Copyright 2024-2025 Lie Yan

import Foundation

public struct TextLocation: Equatable, Hashable, CustomStringConvertible {
    var path: [RohanIndex]
    /** character offset in text node; or node index in element node */
    var offset: Int

    internal init(_ path: [RohanIndex], _ offset: Int) {
        precondition(offset >= 0)
        self.path = path
        self.offset = offset
    }

    public func compare(_ location: TextLocation) -> ComparisonResult? {
        func comparePath(_ lhs: [RohanIndex], _ rhs: [RohanIndex]) -> ComparisonResult? {
            guard let (lhs, rhs) = zip(lhs, rhs).first(where: !=)
            else { return ComparableComparator().compare(lhs.count, rhs.count) }

            switch (lhs, rhs) {
            case let (.index(lhs), .index(rhs)):
                return ComparableComparator().compare(lhs, rhs)
            case let (.mathIndex(lhs), .mathIndex(rhs)):
                return ComparableComparator().compare(lhs, rhs)
            case let (.gridIndex(lhs), .gridIndex(rhs)):
                return ComparableComparator().compare(lhs, rhs)
            case _:
                return nil
            }
        }

        guard let comparePath = comparePath(path, location.path) else { return nil }
        return comparePath == .orderedSame
            ? ComparableComparator().compare(offset, location.offset)
            : comparePath
    }

    public var description: String {
        return "[" + path.map(\.description).joined(separator: ",") + "]:\(offset)"
    }

    public static func == (lhs: TextLocation, rhs: TextLocation) -> Bool {
        return lhs.path == rhs.path && lhs.offset == rhs.offset
    }
}
