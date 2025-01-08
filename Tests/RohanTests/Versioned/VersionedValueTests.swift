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
        value.alterVersion(VersionId(3))
        value.set("b")
        #expect(value.get() == "b")
        #expect(value.get(VersionId(2)) == "a")
        value.set("a")
        #expect(value.get() == "a")
        // version 5
        value.alterVersion(VersionId(5))
        value.set("c")
        #expect(value.get() == "c")
        #expect(value.get(VersionId(3)) == "a")
        // version 7, 9
        value.alterVersion(VersionId(7))
        value.set("d")
        value.alterVersion(VersionId(9))
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

        array.alterVersion(target: VersionId(3))
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
        let doc = sampleDocument(version)
        #expect(doc.synopsis(version) == "The |quick |brown |fox |a = b")

        do {
            let version = VersionId(3)

            let head = doc.getChild(0) as! ElementNode

            head.beginEditing(for: version)
            head.removeChild(at: 0)
            head.insertChild(TextNode("A ", version), at: 0)
            head.endEditing()

            #expect(doc.synopsis(version) == "A |quick |brown |fox |a = b")
        }

        #expect(doc.synopsis(VersionId(2)) == "The |quick |brown |fox |a = b")
        #expect(doc.synopsis(VersionId(4)) == "A |quick |brown |fox |a = b")

        doc.dropVersions(through: VersionId(2))
        #expect(doc.synopsis(VersionId(5)) == "The |quick |brown |fox |a = b")
    }

    static func sampleDocument(_ version: VersionId) -> ContentNode {
        ContentNode([
            HeadingNode(
                level: 1,
                [
                    TextNode("The "),
                    EmphasisNode([
                        TextNode("quick "),
                    ]),
                ]
            ),
            ParagraphNode([
                TextNode("brown "),
                EmphasisNode([
                    TextNode("fox "),
                ]),
                EquationNode(isBlock: false,
                             nucleus: ContentNode([
                                 TextNode("a = b"),
                             ])),
            ]),
        ])
    }
}
