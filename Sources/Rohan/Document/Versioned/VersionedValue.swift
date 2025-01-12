// Copyright 2024-2025 Lie Yan

import SatzAlgorithms

/** Persistent value */
internal struct VersionedValue<T> {
    public private(set) var currentVersion: VersionId

    @usableFromInline
    internal var _store: ContiguousArray<_Item> // Invariant: non-empty

    public var lastVersion: VersionId {
        @inline(__always) get { _store.last.unsafelyUnwrapped.version }
    }

    internal var _lastValue: T {
        @inline(__always) get { _store.last.unsafelyUnwrapped.value }
    }

    @usableFromInline
    internal struct _Item {
        @usableFromInline
        internal var version: VersionId
        @usableFromInline
        internal var value: T

        @inlinable
        internal init(_ version: VersionId, _ value: T) {
            self.version = version
            self.value = value
        }
    }

    @inlinable
    public init(_ value: T, _ version: VersionId = .defaultInitial) {
        self.currentVersion = version
        self._store = [_Item(version, value)]
    }

    /** Return the index of the value that is effective at the given version */
    public func effectiveIndex(for target: VersionId) -> Int {
        precondition(_store[0].version <= target)
        let n = Satz.upperBound(_store, target) { $0 < $1.version }
        return n - 1
    }

    /** Return the value at given version */
    public func get(_ version: VersionId) -> T {
        if version >= lastVersion { return _lastValue }
        return _store[effectiveIndex(for: version)].value
    }

    /** Return the value at the current version */
    public func get() -> T { get(currentVersion) }

    /** Set the value at the current version */
    public mutating func set(_ value: T) where T: Equatable {
        precondition(currentVersion >= lastVersion)

        if currentVersion > lastVersion {
            if _lastValue != value {
                _store.append(_Item(currentVersion, value))
            }
        }
        else {
            let count = _store.count
            if count == 1 {
                _store[0].value = value
            }
            // count > 1
            else if _store[count - 2].value == value {
                _store.removeLast()
            }
            else {
                _store[count - 1].value = value
            }
        }
    }

    public mutating func set(_ value: T) {
        precondition(currentVersion >= lastVersion)

        if currentVersion > lastVersion {
            _store.append(_Item(currentVersion, value))
        }
        else {
            _store[_store.count - 1].value = value
        }
    }

    public func isChanged() -> Bool {
        lastVersion == currentVersion
    }

    public func isChanged(_ version: VersionId) -> Bool {
        _store[effectiveIndex(for: version)].version == version
    }

    public func isChanged(from: VersionId, to: VersionId) -> Bool {
        effectiveIndex(for: from) != effectiveIndex(for: to)
    }

    /** Advance the current version to `target` */
    public mutating func advanceVersion(to target: VersionId) {
        precondition(target >= currentVersion)
        currentVersion = target
    }

    /** Discard versions until the value for `target` becomes effective. */
    public mutating func dropVersions(through target: VersionId) {
        if target >= currentVersion { return }

        // n = card { v | v <= target }
        let n = Satz.upperBound(_store, target) { $0 < $1.version }
        if n != _store.count {
            _store.removeLast(_store.count - n)
        }
        currentVersion = _store[n - 1].version
    }
}
