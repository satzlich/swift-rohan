// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct VersionedValueTests {
    @Test
    static func versionedValues() {
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

    @Test
    static func versionedArrays() {
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

    @Test
    static func versionedNodes() {
        let version = VersionId(1)
        let content = NodeTests.sampleContent()
        #expect(content.synopsis(for: version) == "The |quick |brown |fox |a = b")

        do {
            let version = VersionId(3)

            let head = content.getChild(0) as! ElementNode

            head.beginEditing(for: version)
            head.removeChild(at: 0)
            head.insertChild(TextNode("A ", version), at: 0)
            head.endEditing()

            #expect(content.synopsis(for: version) == "A |quick |brown |fox |a = b")
        }

        #expect(content.synopsis(for: VersionId(2)) == "The |quick |brown |fox |a = b")
        #expect(content.synopsis(for: VersionId(4)) == "A |quick |brown |fox |a = b")

        content.dropVersions(through: VersionId(2))
        #expect(content.synopsis(for: VersionId(5)) == "The |quick |brown |fox |a = b")
    }
}
