// Copyright 2024 Lie Yan

@testable import Rohan_2
import Foundation
import XCTest

typealias TestString = PieceTable<Character>
extension TestString {
    func toString() -> String {
        String(self)
    }
}

// MARK: - PieceTableTests

final class PieceTableTests: XCTestCase {
    func testEmpty() {
        var string = TestString()
        XCTAssertEqual(string.count, 0)

        // insert 0...9
        string.insert(contentsOf: "0123456789", at: string.startIndex)
        XCTAssertEqual(string.count, 10)

        // remove 3 ..< 6
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.removeSubrange(l ..< u)
            XCTAssertEqual(string.count, 7)
            XCTAssertEqual(string.toString(), "0126789")
        }

        // replace 678 with 345
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.replaceSubrange(l ..< u, with: "345")
            XCTAssertEqual(string.toString(), "0123459")
        }
    }

    func testInitial() {
        var string = TestString("0123456789")
        XCTAssertEqual(string.count, 10)

        // remove 3 ..< 6
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.removeSubrange(l ..< u)
            XCTAssertEqual(string.count, 7)
            XCTAssertEqual(string.toString(), "0126789")
        }

        // replace 678 with 345
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.replaceSubrange(l ..< u, with: "345")
            XCTAssertEqual(string.toString(), "0123459")
        }
    }

    func testSubsequence() {
        var string = TestString("0123456789")
        XCTAssertEqual(string.count, 10)

        // remove 3 ..< 6
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.removeSubrange(l ..< u)
            XCTAssertEqual(string.count, 7)
            XCTAssertEqual(string.toString(), "0126789")
        }

        // subsequence 2 ..< 5
        do {
            let l = string.index(string.startIndex, offsetBy: 2)
            let u = string.index(string.startIndex, offsetBy: 5)
            let substring = TestString(string[l ..< u])
            XCTAssertEqual(substring.toString(), "267")
        }

        // subsequence 2 ..< 2
        do {
            let l = string.index(string.startIndex, offsetBy: 2)
            let u = string.index(string.startIndex, offsetBy: 2)
            let substring = TestString(string[l ..< u])
            XCTAssertEqual(substring.toString(), "")
        }
    }
}
