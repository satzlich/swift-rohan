// Copyright 2024-2025 Lie Yan

import Foundation

struct VersionedArray<T> {
    public var currentVersion: VersionId {
        backstore.currentVersion
    }

    private var backstore: VersionedValue<Array<T>>

    init(_ elements: Array<T>, _ version: VersionId) {
        self.backstore = VersionedValue(elements, version)
    }

    public func count(_ version: VersionId) -> Int {
        backstore.get(version).count
    }

    public func count() -> Int {
        count(currentVersion)
    }

    public func at(_ i: Int, _ version: VersionId) -> T {
        backstore.get(version)[i]
    }

    public func at(_ i: Int) -> T {
        at(i, currentVersion)
    }

    public mutating func insert(_ value: T, at i: Int) {
        var array = backstore.get(currentVersion)
        array.insert(value, at: i)
        backstore.set(array)
    }

    public mutating func remove(at i: Int) {
        var array = backstore.get(currentVersion)
        array.remove(at: i)
        backstore.set(array)
    }

    public mutating func removeSubrange(_ range: Range<Int>) {
        var array = backstore.get(currentVersion)
        array.removeSubrange(range)
        backstore.set(array)
    }

    public func isChanged() -> Bool {
        backstore.isChanged()
    }

    public func isChanged(from: VersionId, to: VersionId) -> Bool {
        backstore.isChanged(from: from, to: to)
    }

    public mutating func alterVersion(target: VersionId) {
        backstore.alterVersion(target)
    }

    public mutating func dropVersions(through target: VersionId) {
        backstore.dropVersions(through: target)
    }

    public mutating func dropVersion() {
        backstore.dropVersion()
    }
}
