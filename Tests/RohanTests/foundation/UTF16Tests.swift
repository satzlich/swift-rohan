// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite
struct UTF16Tests {
    @Test
    static func unicodeScalars() {
        let unicodeScalar: UnicodeScalar = "😀"

        let unichars = unicodeScalar.utf16.map { $0 }

        #expect(unichars[0] == 55357)
        #expect(unichars[1] == 56832)

        let combinedValue = UTF16.combineSurrogates(unichars[0], unichars[1])
        #expect(UnicodeScalar(combinedValue) == unicodeScalar)
    }
}
