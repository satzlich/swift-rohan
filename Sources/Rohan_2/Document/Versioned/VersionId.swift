// Copyright 2024-2025 Lie Yan

public struct VersionId: Equatable, Hashable, Comparable {
    let rawValue: Int

    public init(_ rawValue: Int) {
        self.rawValue = rawValue
    }

    public static func < (lhs: VersionId, rhs: VersionId) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static let defaultInitial = VersionId(-1)
}
