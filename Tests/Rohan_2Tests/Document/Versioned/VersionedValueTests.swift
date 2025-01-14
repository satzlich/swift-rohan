// Copyright 2024-2025 Lie Yan

@testable import Rohan_2
import Foundation
import Testing

struct VersionedValueTests {
    @Test
    static func test_VersionedValue() {
        typealias T = VersionedValue<String>

        // version 0
        var value = T("a", VersionId(0))
        #expect(value.get() == "a")
        // version 3
        value.advanceVersion(to: VersionId(3))
        value.set("b")
        #expect(value.get() == "b")
        #expect(value.get(VersionId(2)) == "a")
        value.set("a")
        #expect(value.get() == "a")
        // version 5
        value.advanceVersion(to: VersionId(5))
        value.set("c")
        #expect(value.get() == "c")
        #expect(value.get(VersionId(3)) == "a")
        // version 7, 9
        value.advanceVersion(to: VersionId(7))
        value.set("d")
        value.advanceVersion(to: VersionId(9))
        value.set("e")
        #expect(value.get(VersionId(8)) == "d")
        // revert through version 3
        value.dropVersions(through: VersionId(3))
        #expect(value.currentVersion == VersionId(0))
        #expect(value.get(VersionId(100)) == "a")
    }
}
