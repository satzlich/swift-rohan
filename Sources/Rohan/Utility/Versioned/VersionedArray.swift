// Copyright 2024-2025 Lie Yan

import Foundation

public struct VersionedArray<T> {
    public var currentVersion: VersionId { _backstore.currentVersion }

    public var lastVersion: VersionId { _backstore.lastVersion }

    var _backstore: VersionedValue<Array<T>>

    public init(_ elements: Array<T>, _ version: VersionId) {
        self._backstore = VersionedValue(elements, version)
    }

    public func count(_ version: VersionId) -> Int {
        _backstore.get(version).count
    }

    public func count() -> Int {
        count(currentVersion)
    }

    public func at(_ i: Int, _ version: VersionId) -> T {
        _backstore.get(version)[i]
    }

    public func at(_ i: Int) -> T {
        at(i, currentVersion)
    }

    public mutating func insert(_ value: T, at i: Int) {
        precondition(currentVersion >= lastVersion)

        var array = _backstore.get(currentVersion)
        array.insert(value, at: i)
        _backstore.set(array)
    }

    public mutating func insert(contentsOf elements: some Collection<T>, at i: Int) {
        precondition(currentVersion >= lastVersion)

        var array = _backstore.get(currentVersion)
        array.insert(contentsOf: elements, at: i)
        _backstore.set(array)
    }

    public mutating func remove(at i: Int) -> T {
        precondition(currentVersion >= lastVersion)

        var array = _backstore.get(currentVersion)
        let removed = array.remove(at: i)
        _backstore.set(array)
        return removed
    }

    public mutating func removeSubrange(_ range: Range<Int>) {
        precondition(currentVersion >= lastVersion)

        var array = _backstore.get(currentVersion)
        array.removeSubrange(range)
        _backstore.set(array)
    }

    public func isChanged() -> Bool {
        _backstore.isChanged()
    }

    public func isChanged(from: VersionId, to: VersionId) -> Bool {
        _backstore.isChanged(from: from, to: to)
    }

    public mutating func advanceVersion(to target: VersionId) {
        _backstore.advanceVersion(to: target)
    }

    public mutating func dropVersions(through target: VersionId) {
        _backstore.dropVersions(through: target)
    }
}
