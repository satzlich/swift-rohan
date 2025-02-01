// Copyright 2024-2025 Lie Yan

@testable import Rohan
import _RopeModule
import Foundation
import Testing

struct NodePoplicyTests {
    @Test
    static func test_isBlock() {
        let text = TextNode("Abc")
        #expect(text.isBlock == false)

        let heading = HeadingNode(level: 1, [text])
        #expect(heading.isBlock == true)

        let paragraph = ParagraphNode([text.deepCopy()])
        #expect(paragraph.isBlock == true)
    }

    @Test
    static func testPadding() {
        #expect(RootNode.startPadding == false)
        #expect(RootNode.endPadding == false)
        #expect(ContentNode.startPadding == false)
        #expect(ContentNode.endPadding == false)
        #expect(ParagraphNode.startPadding == false)
        #expect(ParagraphNode.endPadding == true)
    }
}
