// Copyright 2024-2025 Lie Yan

import SatzAlgorithms

struct VersionIdArray: ExpressibleByArrayLiteral {
    private var array: ContiguousArray<VersionId> = []

    public init(arrayLiteral elements: VersionId...) {
        self.array = ContiguousArray(elements)
    }

    public var isEmpty: Bool { array.isEmpty }
    public var count: Int { array.count }
    public var last: VersionId? { array.last }

    public func contains(_ version: VersionId) -> Bool {
        Satz.binarySearch(array, version)
    }

    /** Return the index of the value that is effective at the given version */
    public func effectiveIndex(for version: VersionId) -> Int {
        // argmax { v | v <= version }
        Satz.upperBound(array, version) - 1
    }

    /** Advance the current version to `version` */
    public mutating func advance(to version: VersionId) {
        if array.isEmpty || array.last! < version {
            array.append(version)
        }
        assert(array.last! == version)
    }

    /** Drop all versions greater than the given version */
    public mutating func drop(through version: VersionId) {
        // n = card { v | v <= version }
        let n = Satz.upperBound(array, version)
        if n != array.count {
            array.removeLast(array.count - n)
        }
    }
}
