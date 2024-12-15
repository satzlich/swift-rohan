// Copyright 2024 Lie Yan

import Foundation

enum CIndex: Equatable, Hashable, Codable {
    case regularIndex(RegularIndex)
    case gridIndex(GridIndex)

    static func regularIndex(_ intValue: Int) -> CIndex {
        .regularIndex(RegularIndex(intValue))
    }

    static func gridIndex(row: Int, column: Int) -> CIndex {
        .gridIndex(GridIndex(row: row, column: column))
    }
}

struct RegularIndex: Equatable, Hashable, Codable, ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int

    let intValue: Int

    init(_ intValue: Int) {
        precondition(Self.validate(intValue: intValue))
        self.intValue = intValue
    }

    init(integerLiteral value: IntegerLiteralType) {
        self.intValue = value
    }

    static func validate(intValue: Int) -> Bool {
        intValue >= 0
    }
}

struct GridIndex: Equatable, Hashable, Codable {
    let row: Int
    let column: Int

    init(row: Int, column: Int) {
        precondition(Self.validate(row: row) && Self.validate(column: column))

        self.row = row
        self.column = column
    }

    /*
      We follow the practice of Microsoft Word.
      Column count must be between 1 and 63.
      Row count must be between 1 and 32767.
     */

    static func validate(row: Int) -> Bool {
        0 ..< 32767 ~= row
    }

    static func validate(column: Int) -> Bool {
        0 ..< 63 ~= column
    }
}

struct TreePath: Equatable, Hashable {
    let indices: [CIndex]

    init(_ indices: [CIndex] = []) {
        self.indices = indices
    }

    init(_ indices: ArraySlice<CIndex>) {
        self.indices = Array(indices)
    }

    func appended(_ tail: TreePath) -> TreePath {
        TreePath(indices + tail.indices)
    }

    func appended(_ tail: CIndex) -> TreePath {
        TreePath(indices + [tail])
    }

    func prepended(_ head: TreePath) -> TreePath {
        TreePath(head.indices + indices)
    }

    func prepended(_ head: CIndex) -> TreePath {
        TreePath([head] + indices)
    }
}
