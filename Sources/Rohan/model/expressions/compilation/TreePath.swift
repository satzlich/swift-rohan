// Copyright 2024 Lie Yan

import Foundation

struct ChildIndex: Equatable, Hashable {
    let rawValue: Int

    static func regular(_ value: Int) -> ChildIndex {
        ChildIndex(rawValue: value)
    }

    static func grid(row: Int, column: Int) -> ChildIndex {
        precondition(ChildIndex.validateRow(row))
        precondition(ChildIndex.validateColumn(column))

        return ChildIndex(rawValue: row << 8 | column)
    }

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
}

struct TreePath: Equatable, Hashable {
    let indices: [ChildIndex]

    init(_ indices: [ChildIndex]) {
        self.indices = indices
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
