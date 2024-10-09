// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class UniStringTests: XCTestCase {
    func testEmpty() {
        var string = UniString()
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

        // equality and hash
        let initial = UniString("0123459")
        XCTAssertEqual(string, initial)
        XCTAssertEqual(string.hashValue, initial.hashValue)
    }

    func testInitial() {
        var string = UniString("0123456789")
        XCTAssertEqual(string.count, 10)

        // remove 3 ..< 6
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.removeSubrange(l ..< u)
            XCTAssertEqual(string.count, 7)
            XCTAssertEqual(string.toString(), "0126789")
        }

        // replace "678" with "345"
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.replaceSubrange(l ..< u, with: "345")
            XCTAssertEqual(string.toString(), "0123459")
        }
    }

    func testSurrogatePairs() {
        var string = UniString("0\u{1F30E}2\u{12000}4\u{20000}6\u{1D49C}8\u{F0000}")
        XCTAssertEqual(string.count, 10)

        // remove 3 ..< 6
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.removeSubrange(l ..< u)
            XCTAssertEqual(string.count, 7)
            XCTAssertEqual(string.toString(), "0\u{1F30E}26\u{1D49C}8\u{F0000}")
        }

        // replace 3 ..< 6 with "345"
        do {
            let l = string.index(string.startIndex, offsetBy: 3)
            let u = string.index(string.startIndex, offsetBy: 6)
            string.replaceSubrange(l ..< u, with: "345")
            XCTAssertEqual(string.toString(), "0\u{1F30E}2345\u{F0000}")
        }
    }
}
