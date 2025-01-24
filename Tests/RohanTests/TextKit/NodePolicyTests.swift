// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct NodePoplicyTests {
    @Test
    static func test_Text_validate() {
        #expect(Text.validate(string: "ABC\r\nxyz") == false)
        #expect(Text.validate(string: "ABC\rxyz") == false)
        #expect(Text.validate(string: "ABC\nxyz") == false)
        #expect(Text.validate(string: "ABCxyz") == true)
    }

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

    @Test
    static func testStringLength() {
        do {
            let a = "\r"
            let b = "\n"
            let c = "\r\n"
            let d = "\n\r"
            #expect(a.count == 1)
            #expect(b.count == 1)
            #expect(c.count == 1)
            #expect(d.count == 2)
        }
        do {
            let a: NSString = "\r"
            let b: NSString = "\n"
            let c: NSString = "\r\n"
            let d: NSString = "\n\r"
            #expect(a.length == 1)
            #expect(b.length == 1)
            #expect(c.length == 2)
            #expect(d.length == 2)
        }
        do {
            let a = "a"
            let combiningCircumflex = "\u{0302}"
            let aCircumflex = "a\u{0302}"
            #expect(a.count == 1)
            #expect(combiningCircumflex.count == 1)
            #expect(aCircumflex.count == 1)
        }
    }
}
