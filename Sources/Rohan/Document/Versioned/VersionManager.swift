// Copyright 2024-2025 Lie Yan

final class VersionManager {
    private var counter: Int = 0
    private var current: Int = 0
    private var versions: [VersionId] = [VersionId(0)]

    var currentVersion: VersionId {
        versions[current]
    }

    func canUndo() -> Bool {
        current > 0
    }

    func undo() -> VersionId {
        current -= 1
        return versions[current]
    }

    func canRedo() -> Bool {
        current < versions.count - 1
    }

    func redo() -> VersionId {
        current += 1
        return versions[current]
    }

    func newVersion() -> VersionId {
        versions.removeLast(versions.count - current - 1)
        counter += 1
        versions.append(VersionId(counter))
        current += 1
        return versions[current]
    }
}

struct VersionId: Equatable, Hashable, Comparable {
    let rawValue: Int

    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }

    static func < (lhs: VersionId, rhs: VersionId) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    static let defaultInitial = VersionId(-1)
}
