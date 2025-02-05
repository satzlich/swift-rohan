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

    /** Conversion between offset and layoutOffset */
    @Test
    static func testOffsetConversion() {
        let text = TextNode("ab😀de")
        #expect(text.layoutLength == 6)

        func characterAt(_ offset: Int) -> Character {
            let string = text.bigString
            return string[string.index(string.startIndex, offsetBy: offset)]
        }

        #expect(characterAt(2) == "😀")
        #expect(characterAt(3) == "d")
        #expect(characterAt(4) == "e")
    }

    @Test
    static func test_isBlock() {
        let text = TextNode("Abc")
        #expect(text.isBlock == false)
    }

    @Test
    static func test_intrinsicLength_extrinsicLength() {
        let text = TextNode("ab😀")
        #expect(text.intrinsicLength == 3)
        #expect(text.extrinsicLength == 3)
    }

    @Test
    static func test_layoutLength() {
        let text = TextNode("ab😀")
        #expect(text.layoutLength == 4)
    }
}
