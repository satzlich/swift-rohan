// Copyright 2024-2025 Lie Yan

import SatzAlgorithms

/**
 Persistent value
 */
struct VersionedValue<T> {
    /** current global version */
    public private(set) var currentVersion: VersionId

    /** latest version (can be greater than current version) */
    public var latestVersion: VersionId {
        versions.last!
    }

    /**
     - Invariant: Neighbouring values must differ. Current version >= last.version
     */
    private var versions: VersionIdArray
    private var values: ContiguousArray<T>

    public init(_ value: T, _ version: VersionId = .defaultInitial) {
        self.currentVersion = version
        self.versions = [version]
        self.values = [value]
    }

    /**
     Return the index of the value that is effective at the given version
     */
    private func effectiveIndex(for target: VersionId) -> Int {
        precondition(versions[0] <= target)
        return versions.effectiveIndex(for: target)
    }

    /**
     Return the value at given version
     */
    public func get(_ version: VersionId) -> T {
        if version >= versions.last! {
            return values.last!
        }
        return values[effectiveIndex(for: version)]
    }

    /**
     Return the value at the current version
     */
    public func get() -> T {
        get(currentVersion)
    }

    /**
     Set the value at the current version
     */
    public mutating func set(_ value: T) where T: Equatable {
        let lastVersion = versions.last!

        precondition(currentVersion >= lastVersion)

        if currentVersion > lastVersion {
            if values.last! != value {
                versions.append(currentVersion)
                values.append(value)
            }
        }
        else {
            assert(currentVersion == lastVersion)

            let count = values.count
            if count == 1 {
                values[0] = value
            }
            else if values[count - 2] == value {
                versions.removeLast()
                values.removeLast()
            }
            else {
                values[count - 1] = value
            }
        }
    }

    public mutating func set(_ value: T) {
        let lastVersion = versions.last!
        precondition(currentVersion >= lastVersion)

        if currentVersion > lastVersion {
            versions.append(currentVersion)
            values.append(value)
        }
        else {
            assert(currentVersion == lastVersion)

            // update last
            let count = values.count
            values[count - 1] = value
        }
    }

    public func isChanged() -> Bool {
        versions.last! == currentVersion
    }

    public func isChanged(_ version: VersionId) -> Bool {
        versions[effectiveIndex(for: version)] == version
    }

    public func isChanged(from: VersionId, to: VersionId) -> Bool {
        effectiveIndex(for: from) != effectiveIndex(for: to)
    }

    /**
     Advance the current version to `target`
     */
    public mutating func advanceVersion(to target: VersionId) {
        precondition(target >= currentVersion)
        currentVersion = target
    }

    /**
     Discard versions until the value for `target` becomes effective.
     */
    public mutating func dropVersions(through target: VersionId) {
        if target >= currentVersion { return }

        // first = argmin { version | version > target }
        let first = versions.upperBound(for: target)
        if first != versions.count {
            let count = versions.count - first
            versions.removeLast(count)
            values.removeLast(count)
        }
        currentVersion = versions[first - 1]
    }
}
