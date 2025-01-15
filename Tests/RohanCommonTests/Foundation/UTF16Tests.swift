// Copyright 2024-2025 Lie Yan

import Foundation
import RohanCommon
import Testing

struct UTF16Tests {
    @Test
    static func test_combineSurrogates() {
        let unicodeScalar: UnicodeScalar = "😀"

        let unichars = unicodeScalar.utf16.map { $0 }

        #expect(unichars[0] == 55357)
        #expect(unichars[1] == 56832)

        let combinedValue = UTF16.combineSurrogates(unichars[0], unichars[1])
        #expect(UnicodeScalar(combinedValue) == unicodeScalar)
    }

    @Test
    static func testStringLength() {
        let string = "😀"
        let nsString = string as NSString
        let attributedString = NSAttributedString(string: string)

        #expect(string.count == 1)
        #expect(nsString.length == 2)
        #expect(attributedString.length == 2)
    }
}
