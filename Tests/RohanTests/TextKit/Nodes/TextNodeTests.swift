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
        #expect(text.length == 5)
        #expect(text.layoutLength == 6)

        func characterAt(_ offset: Int) -> Character {
            let string = text.string
            return string[string.index(string.startIndex, offsetBy: offset)]
        }

        #expect(text.layoutOffset(for: 2) == 2)
        #expect(text.layoutOffset(for: 3) == 4)
        #expect(text.layoutOffset(for: 4) == 5)

        #expect(text.offset(for: 2) == 2)
        #expect(text.offset(for: 3) == 2)
        #expect(text.offset(for: 4) == 3)
        #expect(text.offset(for: 5) == 4)

        #expect(characterAt(2) == "😀")
        #expect(characterAt(3) == "d")
        #expect(characterAt(4) == "e")
    }

    @Test
    static func test_getChild_getOffset() {
        let text = TextNode("a😀b")
        for i in (0 ... 3) {
            let index = RohanIndex.arrayIndex(i)
            #expect(text.getChild(index) == nil)
            #expect(text.getOffset(before: index) == i)
        }
    }

    @Test
    static func test_isBlock() {
        let text = TextNode("Abc")
        #expect(text.isBlock == false)
    }
}
