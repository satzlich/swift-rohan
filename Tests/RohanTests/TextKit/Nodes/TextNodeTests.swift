// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct TextNodeTests {
    @Test
    static func testValidation() {
        #expect(Text.validate(string: "ABC\r\nxyz") == false)
        #expect(Text.validate(string: "ABC\rxyz") == false)
        #expect(Text.validate(string: "ABC\nxyz") == false)
        #expect(Text.validate(string: "ABCxyz") == true)
    }

    @Test
    static func test_isBlock() {
        let text = TextNode("Abc")
        #expect(text.isBlock == false)
    }

    @Test
    static func test_intrinsicLength_extrinsicLength() {
        let text = TextNode("ab😀")
        #expect(text.bigString.count == 3)
        #expect(text.extrinsicLength == 3)
    }

    @Test
    static func test_layoutLength() {
        let text = TextNode("ab😀")
        #expect(text.layoutLength == 4)
    }
}
