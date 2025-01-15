// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct VersionedArrayTests {
    @Test
    static func test_VersionedArray() {
        typealias T = VersionedArray<String>

        var array = T(["a", "b"], VersionId(0))
        #expect(array.count() == 2)
        #expect(array.at(0) == "a")
        #expect(array.at(1) == "b")

        array.advanceVersion(to: VersionId(3))
        array.insert("AA", at: 1)
        #expect(array.count() == 3)
        #expect(array.at(0) == "a")
        #expect(array.at(1) == "AA")
        #expect(array.at(2) == "b")

        #expect(array.count(VersionId(2)) == 2)
        #expect(array.at(0, VersionId(2)) == "a")
        #expect(array.at(1, VersionId(2)) == "b")
    }
}
