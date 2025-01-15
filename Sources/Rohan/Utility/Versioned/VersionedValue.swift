// Copyright 2024-2025 Lie Yan

import SatzAlgorithms

/** Persistent value */
public struct VersionedValue<T> {
    public var currentVersion: VersionId { _currentVersion }

    @usableFromInline
    internal var _currentVersion: VersionId

    @usableFromInline
    internal var _store: ContiguousArray<_Item> // Invariant: non-empty

    public var lastVersion: VersionId {
        @inline(__always) get { _store.last!.version }
    }

    internal var _lastValue: T {
        @inline(__always) get { _store.last!.value }
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
        self._currentVersion = version
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
    public func get() -> T { get(_currentVersion) }

    /** Set the value at the current version */
    public mutating func set(_ value: T) where T: Equatable {
        precondition(_currentVersion >= lastVersion)

        if _currentVersion > lastVersion {
            if _lastValue != value {
                _store.append(_Item(_currentVersion, value))
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
        precondition(_currentVersion >= lastVersion)

        if _currentVersion > lastVersion {
            _store.append(_Item(_currentVersion, value))
        }
        else {
            _store[_store.count - 1].value = value
        }
    }

    public func isChanged() -> Bool {
        lastVersion == _currentVersion
    }

    public func isChanged(_ version: VersionId) -> Bool {
        _store[effectiveIndex(for: version)].version == version
    }

    public func isChanged(from: VersionId, to: VersionId) -> Bool {
        effectiveIndex(for: from) != effectiveIndex(for: to)
    }

    /** Advance the current version to `target` */
    public mutating func advanceVersion(to target: VersionId) {
        precondition(target >= _currentVersion)
        _currentVersion = target
    }

    /** Discard versions until the value for `target` becomes effective. */
    public mutating func dropVersions(through target: VersionId) {
        if target >= _currentVersion { return }

        // n = card { v | v <= target }
        let n = Satz.upperBound(_store, target) { $0 < $1.version }
        if n != _store.count {
            _store.removeLast(_store.count - n)
        }
        _currentVersion = _store[n - 1].version
    }
}
