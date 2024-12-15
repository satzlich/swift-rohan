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
        precondition(GridUtils.validate(row: row) && GridUtils.validate(column: column))

        let rawValue = GridUtils.encode(row: row, column: column)
        return ChildIndex(rawValue: rawValue)
    }
}

enum GridUtils {
    enum BitMask {
        static let mask: Int = .init(bitPattern: 0b1111_0000 << (Int.bitWidth - 8))
        static let grid: Int = .init(bitPattern: 0b1001_0000 << (Int.bitWidth - 8))
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

    static func validate(rawValue: Int) -> Bool {
        (rawValue & BitMask.mask) == BitMask.grid
    }

    static func encode(row: Int, column: Int) -> Int {
        precondition(validate(row: row) && validate(column: column))

        // leading bits are `BitMask.grid`
        // 16 bits for row, 8 bits for column
        return BitMask.grid | (row << 8) | column
    }

    static func decode(rawValue: Int) -> (row: Int, column: Int) {
        precondition(validate(rawValue: rawValue),
                     "Invalid encoded value: leading bit must be 1")

        let row = (rawValue >> 8) & ((1 << 16) - 1) // Mask the 16-bit row
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
