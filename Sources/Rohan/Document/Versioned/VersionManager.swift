// Copyright 2024-2025 Lie Yan

final class VersionManager {
    /** Global version counter */
    private var counter: Int = 0
    /** Index of current version */
    private var currentIndex: Int = 0
    /** Version history */
    private var versions: [VersionId] = [VersionId(0)]

    public var currentVersion: VersionId {
        versions[currentIndex]
    }

    public func canUndo() -> Bool {
        currentIndex > 0
    }

    public func undo() -> VersionId {
        currentIndex -= 1
        return versions[currentIndex]
    }

    public func canRedo() -> Bool {
        currentIndex < versions.count - 1
    }

    public func redo() -> VersionId {
        currentIndex += 1
        return versions[currentIndex]
    }

    public func newVersion() -> VersionId {
        // drop all versions after current version
        versions.removeLast(versions.count - currentIndex - 1)
        // create new version
        counter += 1
        versions.append(VersionId(counter))
        // increment current index
        currentIndex += 1
        return versions[currentIndex]
    }
}

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
