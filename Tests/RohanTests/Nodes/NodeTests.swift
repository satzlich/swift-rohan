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
    static func test_range_length() {
        let content = sampleContent()
        let initialVersion = content.subtreeVersion

        let initial =
            """
            (21, [(10, [`4`, (6, [`6`])]), (11, [`6`, (4, [`4`]), (1, [(5, [`5`])])])])
            """

        #expect(
            initial == NodeUtils.rangeLengthSummary(of: content, nil).description
        )

        do {
            let newVersion = VersionId(1)
            content.beginEditing(for: newVersion)
            content.removeChild(at: 0)
            content.insertChild(TextNode("A ", newVersion), at: 0)
            content.endEditing()
        }

        #expect(
            """
            (13, [`2`, (11, [`6`, (4, [`4`]), (1, [(5, [`5`])])])])
            """
                == NodeUtils.rangeLengthSummary(of: content, nil).description
        )

        #expect(
            initial
                == NodeUtils.rangeLengthSummary(of: content, initialVersion).description
        )
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
