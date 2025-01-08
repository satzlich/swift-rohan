// Copyright 2024-2025 Lie Yan

import SatzAlgorithms

struct VersionIdArray: ExpressibleByArrayLiteral {
    private var array: ContiguousArray<VersionId> = []

    public init(arrayLiteral elements: VersionId...) {
        self.array = ContiguousArray(elements)
    }

    public var count: Int {
        array.count
    }

    public var last: VersionId? {
        array.last
    }

    public func contains(_ version: VersionId) -> Bool {
        SortedArrayUtils.binary_search(array, version)
    }

    /**
     Advance the current version to `version`
     */
    public mutating func advance(to version: VersionId) {
        if array.isEmpty || array.last! < version {
            append(version)
        }
        assert(array.last! == version)
    }

    /**
     Drop all versions greater than the given version
     */
    public mutating func drop(through version: VersionId) {
        // result = array.filter { $0 <= version }
        let index = SortedArrayUtils.upper_bound(array, version)
        if index != array.count {
            array.removeLast(array.count - index)
        }
    }

    /**
     Return the index of the value that is effective at the given version
     */
    public func effectiveIndex(for version: VersionId) -> Int {
        SortedArrayUtils.upper_bound(array, version) - 1
    }

    /**
     Return the index of the first version that is greater than the given version

     Return `count` if there is no such version
     */
    public func upperBound(for version: VersionId) -> Int {
        SortedArrayUtils.upper_bound(array, version)
    }

    // MARK: - Array API

    public subscript(_ index: Int) -> VersionId {
        array[index]
    }

    public mutating func append(_ version: VersionId) {
        precondition(array.isEmpty || array.last! < version)

        array.append(version)
    }

    public mutating func removeLast() {
        array.removeLast()
    }

    public mutating func removeLast(_ k: Int) {
        array.removeLast(k)
    }
}
