// Copyright 2024-2025 Lie Yan

@testable import RohanMinimal
import Foundation
import Testing

struct InternalTests {
    @Test
    static func testTextNode() {
        #expect(TextNode.validate(string: "ABC\r\nxyz") == false)
        #expect(TextNode.validate(string: "ABC\rxyz") == false)
        #expect(TextNode.validate(string: "ABC\nxyz") == false)
        #expect(TextNode.validate(string: "ABCxyz") == true)
    }

    @Test
    static func testEquationNode() {
        let equation = EquationNode(isBlock: false)
        #expect(equation.nucleus.parent != nil)
    }

    @Test
    static func testLength() {
        let content = ContentNode([
            TextNode("abc"),
            TextNode("def"),
            TextNode("ghi"),
        ])
        #expect(content.length == 9)
        
        content.removeChild(at: 1)
        #expect(content.length == 6)
    }
}
