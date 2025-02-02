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
    static func testOffset() {
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
    static func testNewlineCharacter() {
        let a = "\r"
        let b = "\n"
        let c = "\r\n"
        let d = "\n\r"
        #expect(a.count == 1)
        #expect(b.count == 1)
        #expect(c.count == 1)
        #expect(d.count == 2)
    }

    @Test
    static func testCombiningCharacter() {
        do {
            let circumflex = "\u{0302}" // combining circumflex
            #expect(circumflex.count == 1)
            let space = " "
            #expect(space.count == 1)

            let combined = space + circumflex
            #expect(combined.count == 1)
            #expect(combined.utf16.count == 2)
        }

        do {
            let a = "a"
            let circumflex = "\u{0302}" // combining circumflex
            let combined = "a\u{0302}"
            #expect(a.count == 1)
            #expect(circumflex.count == 1)
            #expect(combined.count == 1)
        }
    }
}
