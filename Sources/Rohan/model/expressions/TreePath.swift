// Copyright 2024 Lie Yan

import Foundation

struct ChildIndex: Equatable, Hashable {
    let rawValue: Int

    private init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static func regular(_ value: Int) -> ChildIndex {
        precondition(value >= 0)
        return ChildIndex(rawValue: value)
    }

    static func grid(row: Int, column: Int) -> ChildIndex {
        precondition(GridUtils.validateRow(row) && GridUtils.validateColumn(column))

        let rawValue = GridUtils.encodeRowColumn(row, column)
        return ChildIndex(rawValue: rawValue)
    }
}

enum GridUtils {
    /*
      We follow the practice of Microsoft Word.
      Column count must be between 1 and 63.
      Row count must be between 1 and 32767.
     */

    static func validateRow(_ row: Int) -> Bool {
        0 ..< 32767 ~= row
    }

    static func validateColumn(_ column: Int) -> Bool {
        0 ..< 63 ~= column
    }

    static func encodeRowColumn(_ row: Int, _ column: Int) -> Int {
        precondition(validateRow(row) && validateColumn(column))

        // leading bit is 1
        // 24 bits for row, 8 bits for column
        return Int.leadBitMask | (row << 8) | column
    }

    static func decodeRowColumn(_ rawValue: Int) -> (row: Int, column: Int) {
        precondition(rawValue & Int.leadBitMask != 0,
                     "Invalid encoded value: leading bit must be 1")

        let row = (rawValue >> 8) & ((1 << 24) - 1) // Mask the 24-bit row
        let column = rawValue & ((1 << 8) - 1) // Mask the 8-bit column
        return (row, column)
    }
}

struct TreePath: Equatable, Hashable {
    let indices: [ChildIndex]

    init(_ indices: [ChildIndex] = []) {
        self.indices = indices
    }

    init(_ indices: ArraySlice<ChildIndex>) {
        self.indices = Array(indices)
    }

    func appended(_ tail: TreePath) -> TreePath {
        TreePath(indices + tail.indices)
    }

    func appended(_ tail: ChildIndex) -> TreePath {
        TreePath(indices + [tail])
    }

    func prepended(_ head: TreePath) -> TreePath {
        TreePath(head.indices + indices)
    }

    func prepended(_ head: ChildIndex) -> TreePath {
        TreePath([head] + indices)
    }
}
