// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct NodePoplicyTests {
    @Test
    static func test_TextNode_validate() {
        #expect(TextNode.validate(string: "ABC\r\nxyz") == false)
        #expect(TextNode.validate(string: "ABC\rxyz") == false)
        #expect(TextNode.validate(string: "ABC\nxyz") == false)
        #expect(TextNode.validate(string: "ABCxyz") == true)
    }

    @Test
    static func test_isBlock() {
        let text = TextNode("Abc")
        #expect(text.isBlock == false)

        let heading = HeadingNode(level: 1, [text])
        #expect(heading.isBlock == true)

        let paragraph = ParagraphNode([text])
        #expect(paragraph.isBlock == true)
    }
}
