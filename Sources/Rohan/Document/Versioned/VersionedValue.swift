// Copyright 2024-2025 Lie Yan

/**
 Persistent value
 */
struct VersionedValue<T> {
    /** current global version */
    public private(set) var currentVersion: VersionId

    /**
     - Invariant: Neighbouring values must differ. Current version >= last.version
     */
    private var sortedArray: ContiguousArray<VersionValue>

    private struct VersionValue {
        var version: VersionId
        var value: T
    }

    public init(_ value: T, _ version: VersionId = .defaultInitial) {
        self.currentVersion = version
        self.sortedArray = [.init(version: version, value: value)]
    }

    private func effectiveIndex(for target: VersionId) -> Int {
        // result = argmax { (version, _) where version <= target }

        precondition(sortedArray[0].version <= target)

        var i = 0
        var count = sortedArray.count - 1 // length of undertermined range
        while count > 0 {
            let step = (count + 1) / 2

            if sortedArray[i + step].version <= target {
                i += step
                count -= step
            }
            else {
                count = step - 1
            }
        }
        return i
    }

    /**
     Return the value at given version or the current version
     */
    public func get(_ version: VersionId) -> T {
        if version >= sortedArray.last!.version {
            return sortedArray.last!.value
        }
        let index = effectiveIndex(for: version)
        return sortedArray[index].value
    }

    public func get() -> T {
        get(currentVersion)
    }

    /**
     Set the value at the current version
     */
    public mutating func set(_ value: T) where T: Equatable {
        let last = sortedArray.last!

        precondition(currentVersion >= last.version)

        if currentVersion > last.version {
            if last.value != value {
                sortedArray.append(.init(version: currentVersion, value: value))
            }
        }
        else {
            assert(currentVersion == last.version)

            let count = sortedArray.count
            if count == 1 {
                sortedArray[0].value = value
            }
            else if sortedArray[count - 2].value == value {
                sortedArray.removeLast()
            }
            else {
                sortedArray[count - 1].value = value
            }
        }
    }

    public mutating func set(_ value: T) {
        let last = sortedArray.last!

        precondition(currentVersion >= last.version)

        if currentVersion > last.version {
            sortedArray.append(.init(version: currentVersion, value: value))
        }
        else {
            assert(currentVersion == last.version)

            let count = sortedArray.count
            sortedArray[count - 1].value = value
        }
    }

    public func isChanged() -> Bool {
        sortedArray.last!.version == currentVersion
    }

    public func isChanged(_ version: VersionId) -> Bool {
        let index = effectiveIndex(for: version)
        return sortedArray[index].version == version
    }

    public func isChanged(from: VersionId, to: VersionId) -> Bool {
        effectiveIndex(for: from) != effectiveIndex(for: to)
    }

    /**
     Commit the changes at the current version. Then set the current version
     to the given version.

     - Precondition: `target` is greater than the current version
     */
    public mutating func alterVersion(_ target: VersionId) {
        precondition(target >= currentVersion)
        currentVersion = target
    }

    /**
     Discard versions until the value for `target` becomes effective.
     */
    public mutating func dropVersions(through target: VersionId) {
        if currentVersion <= target { return }

        let index = effectiveIndex(for: target)
        sortedArray.removeLast(sortedArray.count - index - 1)
        currentVersion = sortedArray[index].version
    }

    public mutating func dropVersion() {
        dropVersions(through: VersionId(currentVersion.rawValue - 1))
    }
}
