// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct NodeTests {
    @Test
    static func test_synopsis() {
        let content = sampleContent()

        #expect(content.subtreeVersion == VersionId.defaultInitial)
        #expect(content.synopsis() == "The |quick |brown |fox |a = b")
    }

    @Test
    static func test_versioned() {
        let version = VersionId(1)
        let content = sampleContent()
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

    @Test
    static func test_range_length() {
        let content = sampleContent()
        let initialVersion = content.subtreeVersion

        let expectedSummary =
            """
            (21, [(10, [`4`, (6, [`6`])]), (11, [`6`, (4, [`4`]), (1, [(5, [`5`])])])])
            """

        do {
            let summary = NodeUtils.rangeLengthSummary(of: content, nil)
            #expect(expectedSummary == summary.description)
        }

        do {
            let newVersion = VersionId(1)
            content.beginEditing(for: newVersion)
            content.removeChild(at: 0)
            content.insertChild(TextNode("A ", newVersion), at: 0)
            content.endEditing()

            let summary = NodeUtils.rangeLengthSummary(of: content, nil)
            #expect(
                """
                (13, [`2`, (11, [`6`, (4, [`4`]), (1, [(5, [`5`])])])])
                """
                    == summary.description
            )
        }

        do {
            let summary = NodeUtils.rangeLengthSummary(of: content, initialVersion)
            #expect(expectedSummary == summary.description)
        }
    }

    @Test
    static func test_clone() {
        let content = sampleContent()

        do {
            let newVersion = VersionId(1)
            content.beginEditing(for: newVersion)
            content.removeChild(at: 0)
            content.insertChild(TextNode("A ", newVersion), at: 0)
            content.endEditing()

            #expect(content.subtreeVersion == newVersion)
            #expect(content.synopsis() == "A |brown |fox |a = b")
        }

        let newContent = content.clone()

        #expect(newContent.synopsis() == "A |brown |fox |a = b")
        #expect(newContent.subtreeVersion == VersionId.defaultInitial)
    }

    @Test
    static func test_drop() {
        let content = sampleContent()

        do {
            let newVersion = VersionId(3)
            let heading = content.getChild(0) as! HeadingNode

            heading.beginEditing(for: newVersion)
            heading.removeChild(at: 0)
            heading.insertChild(TextNode("A ", newVersion), at: 0)
            heading.endEditing()

            #expect(heading.nodeVersion == newVersion)
            #expect(content.nodeVersion == .defaultInitial)
            #expect(content.synopsis() == "A |quick |brown |fox |a = b")
        }

        let oldVersion = VersionId(2)
        content.dropVersions(through: oldVersion)
        #expect(content.subtreeVersion <= oldVersion)
        #expect(content.maxNestedVersion <= oldVersion)
        #expect(content.nodeVersion == .defaultInitial)
        #expect(content.synopsis() == "The |quick |brown |fox |a = b")
    }

    @Test
    static func test_visitor() {
        final class CountingVisitor: SimpleNodeVisitor<Void> {
            var count = 0
            override func visitNode(_ node: Node, _ context: Void) {
                count += 1
            }
        }

        let content = sampleContent()
        let visitor = CountingVisitor()
        content.accept(visitor, ())
        #expect(visitor.count == 12)
    }

    static func sampleContent() -> ContentNode {
        ContentNode([
            HeadingNode(
                level: 1,
                [
                    TextNode("The "),
                    EmphasisNode(
                        [
                            TextNode("quick "),
                        ]
                    ),
                ]
            ),
            ParagraphNode(
                [
                    TextNode("brown "),
                    EmphasisNode(
                        [
                            TextNode("fox "),
                        ]
                    ),
                    EquationNode(
                        isBlock: false,
                        nucleus: ContentNode(
                            [
                                TextNode("a = b"),
                            ]
                        )
                    ),
                ]
            ),
        ])
    }
}
