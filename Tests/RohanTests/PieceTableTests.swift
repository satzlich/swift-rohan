// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

typealias PTString = PieceTable<Character>
extension PTString {
    func toString() -> String {
        String(self)
    }
}

// MARK: - PieceTableTests

final class PieceTableTests: XCTestCase {
    func testEmpty() {
        var string = PTString()
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
        var string = PTString("0123456789")
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
}
