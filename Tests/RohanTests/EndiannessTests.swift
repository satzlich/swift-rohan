// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class EndiannessTests: XCTestCase {
    func testUnicodeScalar() {
        let character: Character = "😀"

        let unichars = character.utf16.map { $0 }

        XCTAssertEqual(unichars[0], 55357)
        XCTAssertEqual(unichars[1], 56832)

        let combinedValue = UTF16.combineSurrogates(unichars[0], unichars[1])

        XCTAssertEqual(Character(UnicodeScalar(combinedValue)!), character)
    }
}
